ruleset wovyn_buttons {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }
  rule wovyn_Red_pressed {
    select when wovyn Red_pressed
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Red_released {
    select when wovyn Red_released
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Red_clicked {
    select when wovyn Red_pressed
           then wovyn Red_released
           within 3 seconds
  }
  rule wovyn_Green_pressed {
    select when wovyn Green_pressed
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Green_released {
    select when wovyn Green_released
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Blue_pressed {
    select when wovyn Blue_pressed
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Blue_released {
    select when wovyn Blue_released
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Yellow_pressed {
    select when wovyn Yellow_pressed
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
  rule wovyn_Yellow_released {
    select when wovyn Yellow_released
    pre {
      tolog = event:attrs().klog("attrs")
    }
  }
}