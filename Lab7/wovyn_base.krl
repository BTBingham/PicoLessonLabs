ruleset wovyn_base {
  meta {
    
    use module sensor_profile alias profile
    use module io.picolabs.subscription alias subscription
    shares __testing
  }
  global {
    
    //temperature_threshold = 80.0
    
    
    
    spamBrandon = defaction() {
      blah = profile:get_sms_recipient().klog("sent sms");
      event:send({"eci":"Fz6jvdGpe878VmzvXn6nne", "eid":"666", "domain":"sms", "type":"hello", "attrs" : {"to":profile:get_sms_recipient(), "from":"+14805685187", "message":"It's hot time to spam your number every 10 seconds"}}, host="http://localhost:8080")
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
    
    
    
    
    
    pre{
      blah = profile:get_threshold().klog("current Threshold:");
      
      json = event:attr("genericThing").decode()["data"].klog("json: ");
      currentTemp = json["temperature"][0]["temperatureF"].klog("currentTempF: ");
    }

    //send_directive("say", {"something": "Wovyn Heartbeat triggered!"})
    
    fired {
      raise wovyn event "new_temperature_reading"
        attributes {
          "temperature" : currentTemp,
          "timestamp" : time:now()
        }
    }
  }
  
  rule find_high_temps {
    select when wovyn new_temperature_reading// where event:attr("temperatureF") > temperature_threshold
    
    pre{
      currentTemp = event:attr("temperature").klog("currentTempF: ");
    }
    
    //send_directive("say", {"something": "FIND HIGH TEMP"})
    
    fired {
      raise wovyn event "threshold_violation" attributes {
        "temperature" : currentTemp,
        "timestamp" : event:attr("timestamp")
        } if (currentTemp > profile:get_threshold())
    }
    
    
  }
  
  rule threshold_notification {
    select when wovyn threshold_violation
    foreach subscription:established().filter(function(v){v{"Rx_role"} == "Sensor Boss"})
                                      .map(function(v){v{"Tx"}}) setting (x)
    pre {
      blah = event:attr("timestamp").klog ("time: ");
      bluh = event:attr("temperature").klog("temp: ");
      
    }
    
    //spamBrandon()
    event:send({"eci":x, "eid":"666", "domain":"sms", "type":"hello", "attrs" : {"to":profile:get_sms_recipient(), "from":"+14805685187", "message":"It's hot time to spam your number every 10 seconds"}}, host="http://localhost:8080");
          
    //always {                           
    //  Tx_array.map( function(x) {
    //  event:send({"eci":x, "eid":"666", "domain":"sms", "type":"hello", "attrs" : {"to":profile:get_sms_recipient(), "from":"+14805685187", "message":"It's hot time to spam your number every 10 seconds"}}, host="http://localhost:8080")
    //                            });
    //}
    
    
  }
  
  
}
