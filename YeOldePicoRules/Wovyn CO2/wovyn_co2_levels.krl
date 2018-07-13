ruleset wovyn_co2_levels {
  meta {
    shares __testing, co2_levels, co2_levels_after
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "co2_levels" } ],
                  "events": [ ] }
    co2_levels = function() {
      ent:co2_levels
    }
    co2_levels_after = function(timestamp) {
      ent:co2_levels.filter(function(v){v{"timestamp"} > timestamp})
    }
  }
  rule wovyn_new_gas_reading {
    select when wovyn new_gas_reading
    pre {
      reading = event:attr("readings").filter(function(r){r.name=="co2"})[0].klog("reading")
      co2_level = reading{"concentration"}.as("String") + reading{"units"}
      timestamp = event:attr("timestamp")
      this_ten = timestamp.substr(0,15)
      already_recorded = ent:this_ten == this_ten
      new_entry = { "timestamp": timestamp, "concentration": reading{"concentration"}}
    }
    if not already_recorded then noop()
    fired {
      ent:this_ten := this_ten;
      ent:co2_level := co2_level;
      ent:co2_levels := ent:co2_levels.defaultsTo([]).append(new_entry);
      raise wovyn event "co2_level_recorded" attributes new_entry
    }
  }
/*
  rule wovyn_co2_level_recorded {
    select when wovyn co2_level_recorded
    pre {
      considered_high = event:attr("concentration") >= 600
    }
    if considered_high then noop()
    fired {
      raise wovyn event "co2_level_high" attributes event:attrs()
    }
  }
*/
}