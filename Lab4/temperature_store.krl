ruleset temperature_store {
  meta {
    shares __testing, collect_temperatures, clear_temperatures
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "sensor", "type": "reading_reset"},
        { "domain": "wovyn", "type": "new_temperature_reading", "attrs": [ "temperature", "timestamp"] }
      ]
    }
    
  }
  
  
  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      temperature = event:attr("temperature").klog("store temp: ");
      timestamp = event:attr("timestamp").klog("store time: ");
    }
    send_directive("say", {"something": "temp and time recieved"});
    
    always {
      ent:temperatures{timestamp} := temperature;
      blah = ent:temperatures.klog("temp values: ");
    }
    
    
  }
  
  
  
  
    rule collect_threshold_violations {
    select when wovyn threshold_violation
    
  }
  
  
  
    rule clear_temperatures {
    select when sensor reading_reset
    always {
      clear ent:temperatures;
      clear ent:times;
    }
  }
  
  
  
  
  
}
