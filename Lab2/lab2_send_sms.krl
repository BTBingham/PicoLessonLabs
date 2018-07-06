// click on a ruleset name to see its source here
ruleset lab2_send_sms {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Brandon"
    logging on
    shares get_sms , __testing
  }
  
  global {
    get_sms = function(filter) {
      msg = "there should be texts here";
      msg
    }
    __testing = { "queries": [ { "name": "get_sms_messages", "args": [ "filter" ] },
                           { "name": "__testing" } ],
              "events": [ { "domain": "sms", "type": "hello" }]
            }
  }
  
  rule hello_sms {
    select when sms hello
    send_directive("say", {"something": "Hello World"})
  }
  
  
  
}