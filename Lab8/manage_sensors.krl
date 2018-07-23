ruleset manage_sensors {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.subscription alias subscription
    
    shares __testing, temperatures, sensors
  }
  global {
    
    sensors = function () {
      result = ent:active_sensors;
      result
    }
    
    temperatures = function () {
      //result = ent:active_sensors.map( function(x) {
      //                            wrangler:skyQuery(x[1],"temperature_store","temperatures",null)
      //                          });
      //result = subscription:established();
      // Tx_array = subscription:established().filter(function(v){v{"Rx_role"} == "Sensor"})
      //                                 .map(function(v){v{"Tx"}});
                                      
      // result = Tx_array.map( function(x) {
      //                             wrangler:skyQuery(x,"temperature_store","temperatures",null)
      //                           });
      result = {};
      result["report_id"] = ent:reportNumber;
      result["temperature_sensors"] = 1;
      result["responding"] = 0;
      result["temperatures"]= ent:temperatures;
      result
    }
    
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "sensors"}
      , { "name": "temperatures"}
      ] , "events":
      [ { "domain": "sensor", "type": "new_sensor", "attrs" : ["name"] }
      , { "domain": "sensor", "type": "unneeded_sensor", "attrs": [ "name" ] }
      , { "domain": "sensor", "type": "clearList"}
      , { "domain": "test", "type": "sensor_boss"}
      , { "domain": "test", "type": "add_temps"}
      , { "domain": "sensor","type":"notifyNeedReport"}
      ]
    }
  }
  
    rule intialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    
    fired {
      ent:reportNumber := 0;
      ent:temperatures := [];
    }
  }
  
  rule test_create_sensors {
    select when test sensor_boss
    
    always {
      raise sensor event "new_sensor"
        attributes {
          "name" : "ONE"
      };
      raise sensor event "new_sensor"
        attributes {
          "name" : "TWO"
      };
      raise sensor event "new_sensor"
        attributes {
          "name" : "THREE"
      };
      raise sensor event "new_sensor"
          attributes {
            "name" : "FOUR"
      };
    }
  }
  
  rule receive_temperature_report {
    select when sensor receiveReport
    
    pre {
      temp = event:attr("temperatures");
    }
    
    always {
      ent:temperatures := (ent:temperatures != null) => ent:temperatures.append(temp) | temp;
    }
  }
  
  // rule generate_temperature_report {
  //   select when sensor generateReport
    
  //   fired {
  //     ent:reportNumber := ent:reportNumber + 1;
  //     raise sensor event "notifyNeedReport";
  //   }
  // }
  
  
  rule notify_sensors_need_report {
    select when sensor notifyNeedReport
      foreach subscription:established().filter(function(v){v{"Rx_role"} == "Sensor"})
                                      .map(function(v){v{"Tx"}}) setting (x)
        event:send({"eci": x, "domain":"wovyn", "type":"notify_need_report", "attrs":{"reportNumber":ent:reportNumber}});
        
        fired {
          clear ent:temperatures;
          ent:reportNumber := ent:reportNumber + 1 on final;
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
  
  
  rule test_add_temperatures { 
    select when test add_temps
      foreach ent:active_sensors setting (eci)
        foreach [0,1,2] setting (x)
          event:send({"eci": eci[1], "domain":"wovyn", "type":"new_temperature_reading", "attrs":{"temperature":x, "timestamp":x}});
  }
  
  rule manage_sensors {
    select when sensor new_sensor
    // create a new pico to represent the sensor
    pre {
      //ent:active_sensors;
    }
    //send_directive("say", {"message": "Hello " + "Bob"})
   
    fired {
      ent:newChildName := event:attr("name");
      raise wrangler event "child_creation"
        attributes {
          "name" : event:attr("name"), // install rulesets temperature_store, wovyn_base, sensor_profile
          "rids" : ["sensor_profile"
                   ,"wovyn_base"
                   ,"temperature_store"
                   ,"io.picolabs.subscription"]
        } if (ent:active_sensors.none(function(x) {ent:newChildName == x}))
    }
    // storing the value of an event attribute giving the sensor's name and the new sensors
    //pico's ECI in an entity variable called "sensors" that maps its name to the ECI
  
    
    // send a sensor:profile_updated event to the new 
    //child pico to set its name, smsNumber, and default threshold
    
  }
  
  rule new_sensor_initialized {
    select when wrangler child_initialized
    pre {
      temp = [[event:attr("name"),event:attr("eci")]];
      attributes = {
          "new_deviceName" : ent:newChildName, // install rulesets temperature_store, wovyn_base, sensor_profile
          "new_location" : "Somewhere",
          "new_threshold": 86,
          "new_recipient": "+14809079989"
      };
    }
    event:send({"eci":event:attr("eci"), "domain":"sensor", "type":"profile_updated", "attrs":attributes});
    
    
    always {
      
      raise wrangler event "subscription" attributes
      { "name" : "Boss and Sensors",
        "Rx_role": "Sensor",
        "Tx_role": "Sensor Boss",
        "channel_type": "subscription",
        "wellKnown_Tx" : event:attr("eci")
      };
      
      ent:active_sensors := (ent:active_sensors != null) => ent:active_sensors.append(temp) | temp;
      
      blah = ent:active_sensors.klog("active_sensors:");
    }
  }
  
  rule clear_list {
    select when sensor clearList
    
    always {
      clear ent:active_sensors;
    }
  }
  
  rule disband_sensor { // we're not needed?
    select when sensor unneeded_sensor
    
    always {
      ent:active_sensors := ent:active_sensors.filter(function(x) {x[0] != event:attr("name")});
      blah = ent:active_sensors.klog("active_sensors:");
      
      raise wrangler event "child_deletion"
        attributes {
          "name" : event:attr("name")
        }
    }
    
  }
  
}
