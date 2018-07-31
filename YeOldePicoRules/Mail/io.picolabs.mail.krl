ruleset io.picolabs.mail {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }

  rule mail_incoming {
    select when mail received
    pre {
      attrs = event:attrs().klog("attrs")
      headers = attrs{"headers"}
      date = headers{"Date"}.klog("date")
      to = headers{"To"}.klog("to")
      from = headers{"From"}.klog("from")
      subject = headers{"Subject"}.klog("subject")
      text = attrs{"plain"}.klog("text")
    }
    fired {
      raise mail event "parsed" attributes
        { "date":date, "to":to, "from":from, "subject":subject, "text":text }
    }
  }

  rule mail_reaction {
    select when mail parsed to re#b4a2758961bbca8f28bf[+]([^@]*)@cloudmailin.net# setting(eci)
    pre {
      unused = eci.klog("eci")
    }
    event:send({"eci":eci, "domain":"test", "type":"test", "attrs":event:attrs()})
  }
}