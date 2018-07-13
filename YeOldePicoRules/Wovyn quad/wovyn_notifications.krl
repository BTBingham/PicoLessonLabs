ruleset wovyn_notifications {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }

  rule wovyn_battery_level_low {
    select when wovyn battery_level_low
    pre {
      sensor_id = event:attr("sensor_id")
      health_percent = event:attr("health_percent")
      current_voltage = event:attr("current_voltage")
      timestamp = event:attr("timestamp")
      today = timestamp.substr(0,10)
      already_notified = ent:battery_level_low_notify_date == today
    }
    if not already_notified then every {
      http:post("https://hooks.slack.com/services/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",
        body = <<{ "channel": "#wovyn",>>
             + << "text": "Wovyn_0EC86F (#{sensor_id})>>
             + << battery low (#{health_percent}%, #{current_voltage}v)" }>>)
        setting(postResult)
      send_directive("postResult", {"postResult": postResult.klog("postResult")})
    }
    fired {
      ent:battery_level_low_notify_date := today
    }
  }

  rule wovyn_hot_probe {
    select when wovyn hot_probe
    pre {
      temperatureF = event:attr("temperatureF")
      timestamp = event:attr("timestamp")
      hour = timestamp.substr(0,13)
      already_notified = ent:hot_probe_notify_hour == hour
    }
    if not already_notified then every {
      http:post("https://hooks.slack.com/services/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",
        body = <<{ "channel": "#wovyn",>>
             + << "text": "Wovyn_0EC86F hot probe (#{temperatureF})" }>>)
        setting(postResult)
      send_directive("postResult", {"postResult": postResult.klog("postResult")})
    }
    fired {
      ent:hot_probe_notify_hour := hour
    }
  }

  rule wovyn_co2_level_high {
    select when wovyn co2_level_high
    pre {
      concentration = event:attr("concentration")
      timestamp = event:attr("timestamp")
      hour = timestamp.substr(0,13)
      already_notified = ent:co2_high_notify_hour == hour
    }
    if not already_notified then every {
      http:post("https://hooks.slack.com/services/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",
        body = <<{ "channel": "#wovyn",>>
             + << "text": "Wovyn_2BD53F high co2 level (#{concentration} ppm)" }>>)
        setting(postResult)
      send_directive("postResult", {"postResult": postResult.klog("postResult")})
    }
    fired {
      ent:co2_high_notify_hour := hour
    }
  }
}