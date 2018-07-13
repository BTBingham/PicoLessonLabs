ruleset aurora_test {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    newline = (13.chr() + "?" + 10.chr()).as("RegExp")
    var = function(s) {
      p = s.split(re#=#);
      {}.put(p[0],p[1])
    }
    vars = function(s) {
      p = s=>s.split(re#&#)|[];
      p.length() == 1 => var(p[0]) // temporary workaround for `reduce` bug
                       | p.reduce(function(a,b){a.put(var(b))},{})
    }
    parse = function(text,domain) {
      dlpo = domain.length() + 1;
      text.split(newline)
          .filter(function(v){p=v.split(re#/#);p[0]==domain && p.length()==2})
          .map(function(v){p=v.split(re#[?]#);[p[0].substr(dlpo),vars(p[1])]})
    }
  }
  rule test_test {
    select when test test
    foreach parse(event:attr("text"),"aurora") setting(request)
    pre {
      type = request[0].klog("REQUESTED_TYPE")
      attrs = request[1].klog("REQUESTED_ATTRS")
    }
    if request.length() == 2 then noop()
    fired {
      raise aurora event type attributes attrs;
      ent:lastRequest := "aurora/"+type;
      ent:lastAttrs := attrs
    }
  }
}
