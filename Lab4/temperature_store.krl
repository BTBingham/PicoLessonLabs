ruleset temperature_store {
  meta {
    
    provides collect_temperatures, collect_threshold_violations, clear_temperatures
    shares __testing, collect_temperatures, collect_threshold_violations, clear_temperatures, temperatures, threshold_violations, inrange_temperatures
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" },
        { "name": "temperatures"},
        { "name": "threshold_violations"},
        { "name": "inrange_temperatures"}
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "sensor", "type": "reading_reset"},
        { "domain": "wovyn", "type": "new_temperature_reading", "attrs": [ "temperature", "timestamp"] },
        { "domain": "wovyn", "type": "threshold_violation", "attrs": ["temperature","timestamp"]}
      ]
    }
    
    
    temperatures = function() {
      result = ent:temperatures.defaultsTo([]);
      result
    }
    
    
    threshold_violations = function() {
      result = ent:violations.defaultsTo([]);
      result
    }
    
    
    inrange_temperatures = function() {
      
      result = (ent:temperatures != null) => ent:temperatures.filter(function(x) {
        ent:violations.none(function(v) {v == x})
      }) | [];
      // subtract the violations
      result
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
      temp = [[timestamp, temperature]];
      ent:temperatures := (ent:temperatures != null) => ent:temperatures.append(temp) | temp;
      // have to do it this way or else first element will be null
      
      blah = ent:temperatures.klog("temp values: ");
    }
    
    
  }
  
  
  
  
    rule collect_threshold_violations {
    select when wovyn threshold_violation
    pre {
      temperature = event:attr("temperature").klog("store temp: ");
      timestamp = event:attr("timestamp").klog("store time: ");
    }
    send_directive("say", {"something": "violations recieved"});
    always {
      temp = [[timestamp, temperature]];
      ent:violations := (ent:violations != null) => ent:violations.append(temp) | temp;
      // have to do it this way or else first element will be null
      
      blah = ent:violations.klog("temp values: ");
    }
  }
  
  
  
    rule clear_temperatures {
    select when sensor reading_reset
    
    send_directive("say", {"something": "data cleared"});
    always {
      clear ent:temperatures;
      clear ent:violations;
    }
  }
  
  
  
  
  
}
