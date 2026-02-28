---
# delta_html-es2s
title: Add completion workflow note to AGENTS.md
status: completed
type: task
priority: normal
created_at: 2026-02-28T07:19:48Z
updated_at: 2026-02-28T07:20:21Z
---

Add an explicit instruction that before completing a bean, agents should do:
- update changelog
- update docs
- mix format
- mix precommit
- commit

## Todo
- [x] Update AGENTS.md with the requested workflow note
- [x] Verify wording placement is clear and enforceable
- [x] Commit changes (including bean file)

## Summary of Changes

- Added an explicit pre-completion workflow section to AGENTS.md.
- The section now requires, before completing any bean: update changelog, update docs, run mix format, run mix precommit, and commit.
- Verified placement and wording in AGENTS.md for clarity.
