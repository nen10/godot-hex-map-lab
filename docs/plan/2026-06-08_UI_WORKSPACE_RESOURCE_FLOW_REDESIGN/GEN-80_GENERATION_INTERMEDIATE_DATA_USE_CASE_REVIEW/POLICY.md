# GEN-80 Generation Intermediate Data Use-Case Review Policy

Date: 2026-06-08

## Decisions

- Do not add graph-editor UI during this task.
- Separate immediate UI polish, backlog Resource/API work, and research.
- Treat current `_current_data`, `_current_overlay_data`, generation snapshots, and QA rows as evidence of current state, not as the final model.
- Keep Generate focused; use QA for seed comparison and Resources/Document metadata for committed results.

## Non-goals

- Do not implement a Generation Result resource.
- Do not change generation algorithms.
- Do not add analog tests.
