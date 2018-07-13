ruleset wovyn_light {
  meta {
    shares __testing, reading
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }

    lightLevel = function() {
      ent:light;
    }

    reading = function(path) {
      steps = path.split(re#/#);
      mments = ent:lastHeartbeat.genericThing.data{steps[0]};
      mment = mments.filter(function(v){v.name == steps[1]})[0];
      ans = steps[1] + ": " + mment{steps[2]} + " " + mment.units;
      device = ent:lastHeartbeat.property.name;
      time = time:add(ent:lastTimestamp,{"hours": -6}).substr(0,19) + "MT";
      {"text":ans + " (as of " + time + ")","username":device}
    }
  }

  // catch and record light sensor
  rule record_temperature {
    select when wovyn light
    pre {
      data = event:attrs();
    }
    send_directive("Light Data", data);
    fired {
      ent:lastHeartbeat := data;
      ent:lastTimestamp := time:now()
    } finally {

    }
  }

}