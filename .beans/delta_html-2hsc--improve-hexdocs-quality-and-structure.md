---
# delta_html-2hsc
title: Improve HexDocs quality and structure
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:49:09Z
updated_at: 2026-02-28T07:51:35Z
---

Improve hexdocs.pm quality with curated guides and better ExDoc structure inspired by mature libraries.

## Todo
- [x] Audit current docs structure and identify missing guide pages
- [x] Create high-value guide pages (getting started, compatibility/parity, security/options)
- [x] Update ExDoc configuration (extras grouping/order, main/nav polish)
- [x] Update README/changelog with doc improvements where needed
- [x] Run mix format, mix precommit, and mix docs
- [x] Commit changes (including bean file)

## Summary of Changes

- Added a dedicated `docs/` guide set for HexDocs: getting started, rendering options, security policy, and Quill parity notes.
- Updated ExDoc configuration in `mix.exs` to include grouped extras, guide section labeling, and source links/ref for higher-quality hexdocs.pm navigation.
- Added a README pointer to the new HexDocs guides and updated changelog Unreleased notes for the documentation overhaul.
- Validated docs and quality checks with `mix format`, `mix precommit`, and `mix docs`.
