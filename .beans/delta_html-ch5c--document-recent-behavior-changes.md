---
# delta_html-ch5c
title: Document recent behavior changes
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:00:06Z
updated_at: 2026-02-28T07:34:09Z
---

Document recently introduced behavior changes in README/CHANGELOG so consumers can migrate safely.

## Todo
- [x] Document link behavior changes (protocol handling, rel attribute, sanitization fallback)
- [x] Document empty paragraph rendering change (<p></p> vs <p><br/></p>)
- [x] Document checklist list behavior and any semantic-output parity notes
- [x] Add migration notes/examples for common affected outputs

## Summary of Changes

- Added a new README migration section describing recent behavior changes with concrete before/after outputs.
- Documented link behavior updates: `rel="noopener noreferrer"`, allowed protocols (`http`, `https`, `mailto`, `tel`, `sms`), and `about:blank` fallback for malformed/non-whitelisted links.
- Documented empty paragraph rendering change from `<p><br/></p>` to `<p></p>`.
- Documented checklist list rendering for `checked`/`unchecked` via `data-list` and highlighted semantic parity notes for `quill_css` mode.
- Updated changelog entries under Unreleased to capture these migration-relevant behavior changes.
- Ran `mix format` and `mix precommit` successfully.
