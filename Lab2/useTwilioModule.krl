ruleset io.picolabs.use_twilio_v2 {
  meta {
    use module io.picolabs.lesson_keys
    use module io.picolabs.twilio_v2 alias twilio with 
             account_sid = keys:twilio{"account_sid"}
             auth_token =  keys:twilio{"auth_token"}
    shares messages, __testing
  }
 
   global {
    messages = function(filter) {
      result = twilio:get_messages(filter);
      result
    }
    
    __testing = { "queries": [ { "name": "messages", "args": [ "filter" ] },
                           { "name": "__testing" } ],
              "events": [ { "domain": "sms", "type": "hello" }]
            }
  }
 
 
  rule test_send_sms {
    select when sms hello
    
    twilio:send_sms(event:attr("to"),
                    event:attr("from"),
                    event:attr("message")
                  )
  }
}