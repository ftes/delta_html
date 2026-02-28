---
# delta_html-oad6
title: Audit quill_css class coverage
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:00:06Z
updated_at: 2026-02-28T07:31:54Z
---

Audit quill_css mode and ensure class-based output is used everywhere Quill semantic HTML expects classes.

## Todo
- [x] Enumerate Quill class-emitting block formats relevant to DeltaHtml
- [x] Verify DeltaHtml quill_css output for each format/combination
- [x] Add/adjust tests for missing or incorrect class mappings
- [x] Document any intentional non-parity behavior

## Summary of Changes

- Audited Quill semantic class behavior with harness probes across paragraph, header, blockquote, and list combinations.
- Verified that Quill semantic class-emits indent (`ql-indent-*`) while commonly using inline styles for align/direction in semantic output.
- Verified DeltaHtml `quill_css: true` coverage across block types and list-item align/direction behavior.
- Added/expanded tests for class output on header and blockquote blocks, plus nested list-item class behavior in `quill_css` mode.
- Documented intentional non-parity in README/changelog: `quill_css` prefers classes for align/direction even where Quill semantic output may use inline styles.
- Ran `mix format` and `mix precommit` successfully.
