---
# delta_html-izyt
title: Add Credo Styler Dialyxir and CI checks
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:20:48Z
updated_at: 2026-02-28T07:25:39Z
---

Add missing quality tools and wire them into local precommit and CI.

## Todo
- [x] Add credo, styler, and dialyxir deps/config in mix.exs per official setup
- [x] Configure formatter plugins for Styler and run formatting
- [x] Add credo and dialyzer to mix precommit alias
- [x] Update CI workflow to run format, credo, and dialyzer with PLT caching
- [x] Update docs/changelog for the new workflow
- [x] Run mix precommit and commit all changes (including bean file)

## Summary of Changes

- Added `credo` and `dialyxir` dependencies to `mix.exs` (Styler was already present) and configured Dialyzer PLT output in `priv/plts/project.plt` with `plt_add_apps: [:mix]`.
- Kept Styler as a formatter plugin (`.formatter.exs`) and verified formatting by running `mix format`.
- Added `mix precommit` alias to run: format check, compile warnings-as-errors, credo strict, dialyzer, and tests.
- Added `def cli/0` preferred envs so `precommit`, `credo`, and `dialyzer` run in `:test`.
- Updated CI workflow to run format, credo, compile, tests, and dialyzer, including GitHub cache restore/save for Dialyzer PLTs in `priv/plts`.
- Updated docs/changelog to document the new development and CI quality checks, including that Styler runs through `mix format`.
- Ran `mix precommit` successfully.
