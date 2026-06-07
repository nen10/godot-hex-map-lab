# P0-03 Test Baseline UX

作成日: 2026-06-07
Queue task: `P0-03`

## Goal

Autopilot implementation phases can proceed only after the current local Godot test environment is known. P0-03 records whether `./tools/test.sh` passes or whether the queue must stop as `BLOCKED_BY_TEST_ENV`.

## Operation Steps

1. Codex runs `./tools/test.sh`.
2. Codex records the Godot version, command result, passing scripts, non-fatal warnings, and log directory behavior.
3. Codex classifies the result as `COMPLETE` when the command passes or `BLOCKED_BY_TEST_ENV` when the environment prevents the command from running.
4. Codex updates the queue so `LD2-01` becomes selectable only when the baseline is complete.

## UX Classification

| Step | Evaluation | Target |
| --- | --- | --- |
| Test environment baseline | 有用 + 追加 | Later implementation tasks can trust the local Test path. |
| Human approval | 不要 + 廃止 | Missing Godot is an environment state, not an approval gate. |

## Non-Goals

- No code implementation.
- No test additions.
- No docs/TEST.md change unless the test command behavior changes.
