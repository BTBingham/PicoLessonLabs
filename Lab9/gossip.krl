ruleset gossip {
  meta {
    //use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.subscription alias subscription
    
    shares __testing, peer, getPeer, debugSeenMessages, debugMySeenMessages, debugRumorMessages, debugTxToOriginId, prepareMessage, needSomething
    , theyHaveSeenLessThanMe, theyNeedMessage, prepareRumors
  }
  global {
    
    
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "peer"}
      , { "name": "getPeer"}
      , { "name": "debugSeenMessages"}
      , { "name": "debugMySeenMessages"}
      , { "name": "debugRumorMessages"}
      , { "name": "debugTxToOriginId"}
      , { "name": "prepareMessage"}
      , { "name": "needSomething", "args":["originID"]}
      , { "name": "prepareRumors", "args":["subscriber"]}
      , { "name": "theyHaveSeenLessThanMe", "args":["myKey","seenMessages","mySeenMessages"]}
      , { "name": "theyNeedMessage", "args":["subscriber","rumor"]}
      ] , "events":
      [ { "domain": "gossip", "type": "rumor", "attrs" : ["messageID", "sequence", "message"] }
      , { "domain": "gossip", "type": "seen", "attrs": [ "name" ] }
      , { "domain": "gossip", "type": "newMessage", "attrs": ["message"] }
      , { "domain": "gossip", "type": "heartbeat"}
      , { "domain": "gossip", "type": "clearAll"}
      ]
    }
    
    peer = function () {
      peer = meta:picoId;
      peer
    }
    
    // this function is tested and works
    theyHaveSeenLessThanMe = function(myKey, seenMessages, mySeenMessages) {
      seenMessages = seenMessages.decode().klog("seenMessages:"); mySeenMessages = mySeenMessages.decode();
      result = (seenMessages == null) => true |// if
      (seenMessages[myKey] == null) => true |// else if
      (seenMessages[myKey] < mySeenMessages[myKey]) => true | //else if
      false;// else
      //result = seenMessages[myKey];
      result
    }
    
    
    
    needSomething = function(originID) {
      theirSeenMessages = ent:seenMessages[originID];
      
      mySeenKeys = ent:mySeenMessages.keys();
      result = mySeenKeys.any(function(x) {
        theyHaveSeenLessThanMe(x, theirSeenMessages, ent:mySeenMessages)
      });
      
    // result = (theirSeenMessages == "{}") => true 
    //   | mySeenKeys.none(function(x){
    //     theyHaveSeenLessThanMe(x, theirSeenMessages, ent:mySeenMessages)
    //   });
      result
    }
    
    getPeer = function() {
      // determine which peer to send a message too
      
      Tx_array = subscription:established().filter(function(v){v{"Rx_role"} == "peer"});
                                      //.map(function(v){v{"Tx"}});
      
      // choose a peer that needs something from me
      Tx_array = Tx_array.filter(function(x){needSomething(x)});
      // use random so I don't choose the same peer everytime
      index = random:integer(0,Tx_array.length()-1);
      //peer = Tx_array[index];
      peer = {};
      peer["Tx"] = Tx_array[index]["Tx"];
      peer["Rx"] = Tx_array[index]["Rx"];
      peer
    }
    
    debugMySeenMessages = function() {
      result = ent:mySeenMessages;
      result
    }
    
    debugSeenMessages = function() {
      result = ent:seenMessages;
      result
    }
    
    debugRumorMessages = function() {
      result = ent:rumorMessages;
      result
    }
    
    debugTxToOriginId = function() {
      result = ent:TxToOriginId;
      result
    }
    
    //tested and working
    theyNeedMessage = function(subscriber, rumor){
      rumor = rumor.decode();
      result = (ent:seenMessages[subscriber][rumor["messageID"]]== null) => true |
      (ent:seenMessages[subscriber][rumor["messageID"]] < rumor["sequence"]) => true|
      false;
      //result = ent:seenMessages[subscriber][rumor["messageID"]];
      result
    }
    
    prepareRumors = function(subscriber) {
      result = ent:rumorMessages.filter(function(x){
          theyNeedMessage(subscriber, x)
      });
      result
    }
    
    prepareMessage = function(subscriber) {
      // return a message to propagate to a SPECIFIC neighbor
      // randomly choose either a seen or rumor message type
      // if it's a rumor randomly choose a message among the rumor messages
      // (preferably not one that they already have)
      
      //seen message
      message = {};
      rand = random:integer(0,1);
      message["type"] = (rand) => "seen" | "rumor";
      message["message"] = (rand) => ent:mySeenMessages | prepareRumors(subscriber);
      
      //message["type"] = "seen";
      //message["message"] = ent:mySeenMessages;
      //message["type"] = "rumor";
      //message["message"] = prepareRumors(subscriber);
      message
    }
    
    update = function() {
      // update the state of who has seen what
    }
    
    send = defaction(subscriber, message) {
      // send a message to a peer
      event:send({"eci": subscriber["Tx"], "domain":"gossip", "type": message["type"], 
      "attrs":{"message": message["message"],
              "originID": meta:picoId,
              "Rx": subscriber["Rx"]
      }});
    }
    
  }



  rule gossip_heartbeat {
    select when gossip heartbeat
    
    pre {
      peer = getPeer();
      message = prepareMessage(peer);
    }
    send(peer, message);
    always {
      update();
    }
  }
  
  rule add_message {
    select when gossip newMessage
    
    always {
      message = {};
      message["messageID"] = meta:picoId;
      message["sequence"] = ent:myMessageNumber;
      message["message"] = event:attr("message");
      
      ent:rumorMessages := (ent:rumorMessages != null) => ent:rumorMessages.append(message) | message;
    
      temp = {};
      temp[meta:picoId] = ent:myMessageNumber;
      ent:mySeenMessages := temp;
      
      
      ent:myMessageNumber := ent:myMessageNumber + 1;
    }
  }

  rule clearAll {
   select when gossip clearAll
   
    always {
      ent:myMessageNumber := 0;
      ent:rumorMessages := [];
      ent:seenMessages := {};
      ent:mySeenMessages := {};
      ent:TxToOriginId := {};
    }
  }

  rule intialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    
    always {
      ent:myMessageNumber := 0;
      ent:rumorMessages := [];
      ent:seenMessages := {};
      ent:mySeenMessages := {};
      ent:TxToOriginId := {};
    }
  }



  rule send_gossip_message {
    select when gossip send_message
    
    
    fired {
      raise gossip event rumor
    }
    
  }

  rule rumor_event {
    select when gossip rumor
      foreach event:attr("message").decode() setting (x)
    always {
      //do something
      message = {};
      message["messageID"] = x["messageID"];
      message["sequence"] = x["sequence"].decode();
      message["message"] = x["message"];
      
      ent:rumorMessages := (ent:rumorMessages != null) => ent:rumorMessages.append(message) | message 
      if (ent:rumorMessages.none(function(y){
        ((y["messageID"] == message["messageID"]) && (y["sequence"].decode() == message["sequence"].decode())).klog(message["messageID"]+ " " + y["messageID"] + " seq: " + message["sequence"] + " " + y["sequence"])
      })).klog("ok to add rumor");
      
      blah = message.klog("message");
      
      temp = ent:mySeenMessages.klog("mySeenMessages");
      temp[message["messageID"]] = ((ent:mySeenMessages[message["messageID"]] == null) && (message["sequence"] == 0)) => 0 |
      (ent:mySeenMessages[message["messageID"]] == (message["sequence"] - 1)) => message["sequence"]|
      null;
      blah = (ent:mySeenMessages[message["messageID"]] == (message["sequence"] - 1)).klog("seenEntry");
      ent:mySeenMessages := temp if (temp[message["messageID"]] != null);
    }
  }

  rule seen_event {
    select when gossip seen
    // this is where our peers tell us what messages they have seen
    
    always {
      seenArray = event:attr("message");
      originID = event:attr("originID").klog("originID");
      Tx = event:attr("Rx");
      temp = ent:TxToOriginId;
      temp[originID] = Tx;
      ent:TxToOriginId := temp;
      
      temp = ent:seenMessages;
      temp[originID] = seenArray;
      ent:seenMessages := temp.klog("seen Messages");
    }
  }
  
  
  rule subscription_request_recieved {
    select when wrangler inbound_pending_subscription_added
    
    pre {
      blah = subscription:wellKnown_Rx().klog("We got a new sub request from:");
    }
    
    fired {
      raise wrangler event "pending_subscription_approval"
        attributes event:attrs
    }
  }
}
