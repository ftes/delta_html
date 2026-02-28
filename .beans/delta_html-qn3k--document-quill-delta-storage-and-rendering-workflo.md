---
# delta_html-qn3k
title: Document Quill Delta storage and rendering workflow
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:57:46Z
updated_at: 2026-02-28T07:59:39Z
---

Explain practical DeltaHtml usage: Quill in frontend, Delta-only storage, editor rehydration, and HTML rendering for web/email.

## Todo
- [x] Add use-case explanation to docs/README
- [x] Add or update guide section with end-to-end workflow
- [x] Update changelog for docs enhancement
- [x] Run mix format and mix precommit
- [x] Commit changes (including bean file)

## Summary of Changes

- Added a clear "What This Is Useful For" section in `README.md` describing the recommended Quill workflow:
  - use Quill in the UI,
  - store only Delta in the backend,
  - rehydrate Quill with stored Delta on edit,
  - render Delta to HTML for display surfaces (web UI, emails, etc.).
- Added the same end-to-end workflow explanation to `docs/getting-started.md` under a dedicated app-workflow section.
- Updated Unreleased changelog notes to include this practical usage documentation improvement.
- Validated with `mix format` and `mix precommit`.
