---
# delta_html-aln6
title: Review link security policy after Quill parity
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:00:06Z
updated_at: 2026-02-28T07:36:54Z
---

Review whether current Quill-matching link behavior is acceptable for this project’s threat model.

## Todo
- [x] Evaluate risk of about:blank fallback for malformed/non-whitelisted links
- [x] Evaluate accepted protocols (http, https, mailto, tel, sms) vs project requirements
- [x] Decide if stricter sanitization should be reintroduced behind option/default
- [x] Document the final security policy and rationale

## Summary of Changes

- Reviewed current Quill-compatible link behavior and identified tradeoff: `about:blank` fallback avoids raw dangerous protocols but still renders clickable links for invalid input.
- Kept default policy as `:quill` for parity (`http|https|mailto|tel|sms`, malformed/non-whitelisted -> `about:blank`).
- Reintroduced stricter sanitization as an explicit option: `link_sanitization: :strict`.
  - Strict mode allows only `http|https|mailto`.
  - Strict mode drops malformed/non-whitelisted links (no fallback link wrapper).
- Implemented policy plumbing in `DeltaHtml.to_html/2` link sanitization path and documented option behavior in moduledoc.
- Added tests covering strict-mode allow/block behavior (`tel`, `sms`, malformed URLs, and dangerous protocols).
- Documented final security policy and migration guidance in README and CHANGELOG.
- Ran `mix format` and `mix precommit` successfully.
