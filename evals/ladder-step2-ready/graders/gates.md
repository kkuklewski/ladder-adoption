---
type: regex
pattern: 'gates:\s*"0->1:pass 1->2:pass 2->3:fail 3->4:locked"'
target: { source: file, path: .ladder/profile.md }
weight: 2
---
