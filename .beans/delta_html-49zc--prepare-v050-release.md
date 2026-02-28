---
# delta_html-49zc
title: Prepare v0.5.0 release
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:41:02Z
updated_at: 2026-02-28T07:42:38Z
---

Release prep for current changes.

## Todo
- [x] Bump package version for release
- [x] Finalize release notes/changelog section for the new version
- [x] Regenerate docs and verify build
- [x] Run mix format and mix precommit
- [x] Commit release prep changes and create git tag

## Summary of Changes

- Bumped package version in `mix.exs` from `0.4.0` to `0.5.0`.
- Cut release notes into `CHANGELOG.md` under `## [0.5.0] - 2026-02-28` and reset `Unreleased` section.
- Regenerated docs with `mix docs` and verified successful generation.
- Ran release validation via `mix format` and `mix precommit`.
- Committed release prep and follow-up beans in commit `cf232ab`.
- Created annotated git tag `v0.5.0` with release highlights.
