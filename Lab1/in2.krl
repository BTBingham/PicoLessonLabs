// click on a ruleset name to see its source here
ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Phil Windley"
    logging on
    shares hello, __testing
  }
  
  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
    __testing = { "queries": [ { "name": "hello", "args": [ "obj" ] },
                           { "name": "__testing" } ],
              "events": [ { "domain": "echo", "type": "hello" },
                          { "domain": "echo", "type": "monkey"} ]
            }
  }
  
  rule hello_bobby {
    select when echo hello
    send_directive("say", {"something": "Hello World"})
  }
  
  rule hello_monkey {
    select when echo monkey
    pre {
         sayHelloToThisPerson = (event:attr("name") => event:attr("name") | "Monkey").klog("debug output:");
    }
    send_directive("say", {"message": "Hello " + sayHelloToThisPerson})
  }
  
  
  
}