---
# delta_html-iy5y
title: Add property tests for link sanitization modes
status: todo
type: task
created_at: 2026-02-28T07:40:50Z
updated_at: 2026-02-28T07:40:50Z
---

Add property/fuzz coverage for link sanitization in both :quill and :strict modes.

## Todo
- [ ] Identify URL input classes to fuzz (schemes, malformed, encoded, quotes, unicode)
- [ ] Add property tests for :quill behavior invariants
- [ ] Add property tests for :strict behavior invariants
- [ ] Document testing strategy and invariants in tests/docs
