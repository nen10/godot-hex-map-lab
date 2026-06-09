# STATE-10 UX

## User Goal

Generate should expose one coherent run state: ready, blocked, queued tile update, generating, cancelling, validating, applying, applied, failed, or preview-ready. Controls should render from that state rather than from unrelated private flags.

## Operation Steps

1. Change generation options or tile/orientation settings.
2. If a heavy tile setting update is needed, the run state reports queued/applying/applied.
3. Press Generate.
4. Progress, cancel availability, validation, apply, completion, failure, and target output status derive from the run state.

## Adopted UX

- Existing Generate behavior remains intact.
- `generation_status()` and `generation_progress_snapshot()` expose the state-machine ViewState.
- Orientation/tile setting apply is represented as queued/applying/applied state.

## Rejected UX

- No modal busy window.
- No broad Generate screen redesign in this task.
- No new analog test.
