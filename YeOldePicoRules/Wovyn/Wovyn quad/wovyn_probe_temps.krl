ruleset wovyn_probe_temps {
  meta {
    shares __testing, temps, tempsDay
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "temps" } ],
                  "events": [ ] }
    temps = function() {
      ent:probeTemps
    }
    tempsDay = function(date) {
      entryMatchesDate = function(e) {
        time:add(e{"timestamp"},{"hours": -6}).substr(0,10)==date
      };
      csvEntry = function(e) {
        mdt = time:add(e{"timestamp"},{"hours": -6});
        time:strftime(mdt, "%F %T")+","+e{"temperatureF"}
      };
      ent:probeTemps.filter(entryMatchesDate).map(csvEntry).join(10.chr())
    }
    probe_temperature_threshold = 90
  }

  // catch and record temperature
  rule record_temperature {
    select when wovyn new_temperature_reading
    pre {
      temperatureData = event:attr("readings")
      temperatureF = temperatureData[0]{"temperatureF"}
      timestamp = event:attr("timestamp")
      new_entry = { "timestamp": timestamp, "temperatureF": temperatureF }
      updated_temps = ent:probeTemps.defaultsTo([]).append(new_entry)
      probe_temperature_high = temperatureF >= probe_temperature_threshold
    }
    if probe_temperature_high then noop()
    fired {
      raise wovyn event "hot_probe" attributes new_entry
    } finally {
      ent:probeTemps := updated_temps
    }
  }

}