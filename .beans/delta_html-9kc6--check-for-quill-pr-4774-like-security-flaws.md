---
# delta_html-9kc6
title: Check for Quill PR 4774-like security flaws
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:00:06Z
updated_at: 2026-02-28T07:12:41Z
---

Investigate https://github.com/slab/quill/pull/4774 and determine whether delta_html has analogous security flaws.

## Todo
- [x] Read and summarize the vulnerability/scenario addressed by Quill PR #4774
- [x] Map the vulnerable code path to DeltaHtml rendering pipeline (if applicable)
- [x] Build reproducer tests in DeltaHtml for equivalent attack inputs
- [x] Report findings and propose fixes (or explain why not applicable)

## Summary of Changes

- Reviewed Quill PR #4774 patch content (formula/video escaping and broader getSemanticHTML escaping work).
- Mapped each attack surface to `delta_html`:
  - `formula`, `video`, and `image` embeds are currently unsupported and dropped from output.
  - HTML attributes are emitted through `LazyHTML`, which escapes attribute values and prevents quote-based attribute breakout.
  - `link` protocols are additionally whitelist-sanitized (`http`, `https`, `mailto`, `tel`, `sms`).
- Added regression tests in `test/delta_html_test.exs` for equivalent payload families:
  - Quote/attribute injection attempts in link href values.
  - Angle bracket and ampersand escaping in link href values.
  - Malicious `formula`, `video`, and `image` embed payload handling (dropped safely).
- Ran verification:
  - `mix test test/delta_html_test.exs`
  - `mix test`
- Result: no analogous exploitable XSS path found for PR #4774 scenarios in current `delta_html` behavior.
