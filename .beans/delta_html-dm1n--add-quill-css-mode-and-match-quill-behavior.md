---
# delta_html-dm1n
title: Add quill_css mode and match Quill behavior
status: completed
type: task
priority: normal
created_at: 2026-02-28T06:45:41Z
updated_at: 2026-02-28T06:53:48Z
---

Implement requested rendering parity updates: keep style output as default, add global :quill_css mode for class-based output where Quill uses classes, and match Quill behavior for other known diffs.

## Todo
- [x] Implement renderer option plumbing for :quill_css (default false)
- [x] Match Quill link behavior (rel attr + protocol/sanitization behavior)
- [x] Match Quill list behavior for checked/unchecked and list-item attrs
- [x] Match Quill empty-paragraph behavior
- [x] Update tests (unit + parity) for new expected behavior and quill_css option
- [x] Run full test suite and summarize

## Summary of Changes

- Added new quill_css render option to DeltaHtml. Default output remains style-based; when enabled, block-level attributes render as Quill classes (ql-align-*, ql-direction-rtl, ql-indent-*).
- Updated link rendering to match Quill behavior: always includes rel="noopener noreferrer", supports http|https|mailto|tel|sms, and sanitizes non-whitelisted/malformed protocols to about:blank (empty link values are dropped).
- Added checklist list support for checked/unchecked with data-list attributes and Quill-like list splitting between checked and unchecked groups.
- Updated empty-line rendering to match Quill semantic HTML (<p></p> instead of <p><br/></p>).
- Updated unit/parity tests for the new behavior and added explicit tests for quill_css mode.
- Verified with full suite: mix test => 50 tests, 0 failures.
