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
    get_sms_messages = function(filter) {

      http:get('https://api.twilio.com/2010-04-01/Accounts/AC6ad23f68c379db6d003b555e90c6d56d/Messages.json', {
        'auth': {
        'user': 'username',
        'pass': 'password',
        'sendImmediately': false
  }
})
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
    send_directive("hello_sms", {"message": "Sent sms to my Cell"})
  }
  
  
  
}