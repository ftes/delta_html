---
# delta_html-00ny
title: Move DeltaHtml docs to README
status: completed
type: task
priority: normal
created_at: 2026-02-28T06:15:32Z
updated_at: 2026-02-28T06:17:47Z
---

Move main docs from DeltaHtml moduledoc into README.md while preserving ExDoc-style links, then update mix.exs docs main pointer.

## Todo
- [x] Inspect current moduledoc, README, and mix.exs docs config
- [x] Migrate main docs content from moduledoc to README.md (ExDoc style)
- [x] Update mix.exs docs main pointer to README
- [x] Verify formatting/build impact and summarize changes

## Summary of Changes

- Consolidated the primary documentation into README.md (usage examples, supported features, plugin notes, extensibility, alternatives).
- Reduced the DeltaHtml moduledoc to a concise API summary that points readers to readme.html for full docs.
- Verified ExDoc generation with mix docs to ensure README can serve as main docs content.
