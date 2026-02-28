---
# delta_html-h41f
title: Replace floki with lazy_html and update deps
status: completed
type: task
priority: normal
created_at: 2026-02-28T06:14:27Z
updated_at: 2026-02-28T06:17:14Z
---

Replace the floki dependency with lazy_html, update all remaining dependencies to latest compatible versions, and verify the project builds/tests.

## Todo
- [x] Inspect current dependencies and floki usage
- [x] Update mix.exs to use lazy_html and bump deps
- [x] Refresh lockfile and resolve compile/test issues
- [x] Run verification commands
- [x] Document summary of changes

## Summary of Changes
- Replaced direct dependency floki with lazy_html in mix.exs.
- Updated HTML serialization/parsing calls from Floki to LazyHTML in lib/delta_html.ex and test/quill_parity_test.exs.
- Adjusted whitespace preservation wrapping so the generated tree remains compatible with LazyHTML.from_tree.
- Updated dependencies to latest compatible versions with mix deps.update --all and removed the stale floki lock entry via mix deps.unlock --unused.
- Verified successfully with mix test (47 tests, 0 failures).
