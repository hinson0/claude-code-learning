---
name: yzb-well-done
enabled: false 
event: stop
action: warn
conditions:
  - field: reason
    operator: regex_match
    pattern: .*
---

yzb, well done!
