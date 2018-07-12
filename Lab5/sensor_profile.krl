ruleset sensor_profile {
  meta {
    shares __testing, get_deviceName, get_location, get_threshold, get_sms_recipient
    provide get_deviceName, get_location, get_threshold, get_sms_recipient
  }
  global {
    
    
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "get_deviceName" }
      , { "name": "get_location" }
      , { "name": "get_threshold"}
      , { "name": "get_sms_recipient"}
      ] , "events":
      [ { "domain": "sensor", "type": "profile_updated", "attrs": ["new_deviceName","new_location","new_threshold", "new_recipient"] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    
    get_deviceName = function() {
      result = ent:deviceName;
      result
    }
    
    get_location = function() {
      result = ent:deviceLocation;
      result
    }
    
    get_threshold = function() {
      result = ent:temperature_threshold;
      result
    }
    
    get_sms_recipient = function() {
      result = ent:sms_recipient;
      result
    }
    
  }
  
  rule intialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    
    //if ent:owners.isnull() then noop();
    
    fired {
      ent:deviceName := "heatSensor";
      ent:deviceLocation := "planetEarth";
      ent:temperature_threshold := 100;
      ent:sms_recipient := "+14809079989";
    }
  }
  
  rule change_sensor_profile {
    select when sensor profile_updated
    
    always {
      // ent:deviceName := event:attr("new_deviceName").klog("new threshold:");
      // ent:deviceLocation := event:attr("new_location").klog("new threshold:");
      // ent:temperature_threshold := event:attr("new_threshold").klog("new threshold:");
      ent:deviceName := (event:attr("new_deviceName") != "" && event:attr("new_deviceName") != null) => event:attr("new_deviceName") | ent:deviceName;
      ent:deviceLocation := (event:attr("new_location") != "" && event:attr("new_location") != null) => event:attr("new_location") | ent:deviceLocation;
      ent:temperature_threshold := (event:attr("new_threshold") != "" && event:attr("new_threshold") != null) => event:attr("new_threshold") | ent:temperature_threshold;
      ent:sms_recipient := (event:attr("new_recipient") != "" && event:attr("new_recipient") != null) => event:attr("new_recipient") | ent:sms_recipient;
    }
    
  }
  
}
