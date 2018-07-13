ruleset wovyn_co2_averages {
  meta {
    shares __testing, latest
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    latest = function() {
      time = time:add(ent:lastTimestamp,{"hours": -7}).substr(0,19) + "MT";
      "As of " + time + " CO2 average was " + ent:lastAverage + "ppm"
    }
  }
  rule wovyn_new_gas_reading {
    select when wovyn new_gas_reading
    pre {
      reading = event:attr("readings").filter(function(r){r.name=="co2"})[0]
      co2_level = reading{"concentration"}
      timestamp = event:attr("timestamp")
    }
    always {
      raise wovyn event "new_concentration"
        attributes {"timestamp": timestamp, "co2": co2_level }
    }
  }
  rule wovyn_co2_average {
    select when count 10 (wovyn new_concentration co2 re#(\d+)#) avg(mean)
    pre {
      average = mean.klog("average")
      timestamp = event:attr("timestamp")
    }
    fired {
      ent:lastTimestamp := timestamp;
      ent:lastAverage := average;
      raise wovyn event "co2_average_recorded" attributes
        { "concentration": average,
          "timestamp": timestamp }
    }
  }
  rule wovyn_co2_average_recorded {
    select when wovyn co2_average_recorded
    pre {
      considered_high = event:attr("concentration") >= 600
    }
    if considered_high then noop()
    fired {
      raise wovyn event "co2_level_high" attributes event:attrs()
    }
  }
}