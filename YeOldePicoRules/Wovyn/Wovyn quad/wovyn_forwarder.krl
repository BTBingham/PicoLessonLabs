ruleset wovyn_forwarder {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }

  rule forward_quad_heartbeat {
    select when wovyn heartbeat
      where property{"name"} == "Wovyn_0EC86F"
    pre {
      sensor_data = event:attrs()
    }
    http:post("http://ec2.bruceatbyu.com:3000/sky/event/cixthvab70000y8qy8wu3js6g/fhb/wovyn/heartbeat",
      json = sensor_data) setting(response)
    always {
      ent:latestQuadResponse := response
    }
  }
  rule forward_co2_heartbeat {
    select when wovyn heartbeat
      where property{"name"} == "Wovyn_2BD53F"
    pre {
      sensor_data = event:attrs()
    }
    http:post("http://ec2.bruceatbyu.com:3000/sky/event/cj20snsmr0002ekqy92q64z3c/fhb/wovyn/heartbeat",
      json = sensor_data) setting(response)
    always {
      ent:latestCO2Response := response
    }
  }
}