# P0-03 Test Baseline Policy

作成日: 2026-06-07
Queue task: `P0-03`

## Decision

`./tools/test.sh` is the baseline command for Autopilot completion proof. If it passes, implementation phases can use the same command as task-level verification. If Godot is missing or the command cannot execute, P0-03 becomes `BLOCKED_BY_TEST_ENV` and implementation phases remain blocked.

## Evidence Requirements

- Command: `./tools/test.sh`
- Godot version from command output.
- Test script pass/fail list.
- Non-fatal warning classification.
- Queue status and proof update.

## Known Non-Fatal Output

`docs/TEST.md` already documents the macOS CA certificate ERROR as non-fatal when the command exits successfully.

## Test Policy

No new tests are added. The task itself is proof that the existing Test path is runnable in the current environment.
