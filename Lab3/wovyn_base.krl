ruleset wovyn_base {
  meta {
    shares __testing
  }
  global {
    
    temperature_threshold = 75.0
    
    spamBrandon = defaction() {
      blah = temperature_threshold.klog("sent sms");
      event:send({"eci":"Fz6jvdGpe878VmzvXn6nne", "eid":"666", "domain":"sms", "type":"hello", "to":"+14809079989", "from":"+14805685187", "message":"It's hot time to spam your number every 10 seconds"}, host="http://localhost:8080")
    }
    
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain" : "wovyn", "type": "heartbeat" }
        //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
  }
  
  rule process_heartbeat {
    select when wovyn heartbeat where event:attr("genericThing") != null
    
    

    //send_directive("say", {"something": "Wovyn Heartbeat triggered!"})
    
    fired {
      raise wovyn event "new_temperature_reading"
        attributes event:attrs
    }
  }
  
  rule find_high_temps {
    select when wovyn new_temperature_reading// where event:attr("temperatureF") > temperature_threshold
    
    pre{
      json = event:attr("genericThing").decode()["data"].klog("json: ");
      currentTemp = json["temperature"][0]["temperatureF"].klog("currentTempF: ");
    }
    
    //send_directive("say", {"something": "FIND HIGH TEMP"})
    
    fired {
      raise wovyn event "threshold_violation" attributes {
        "temperature" : currentTemp,
        "timestamp" : time:new("083023Z")
        } if (currentTemp > temperature_threshold)
    }
    
    
  }
  
  rule threshold_notification {
    select when wovyn threshold_violation
    
    pre {
      blah = event:attr("timestamp").klog ("time: ");
      bluh = event:attr("temperature").klog("temp: ");
    }
    
    //spamBrandon()
    
    
  }
  
  
}
