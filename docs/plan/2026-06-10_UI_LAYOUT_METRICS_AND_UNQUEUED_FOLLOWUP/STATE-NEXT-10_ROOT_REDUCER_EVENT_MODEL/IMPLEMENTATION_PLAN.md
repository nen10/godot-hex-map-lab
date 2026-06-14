# STATE-NEXT-10 Implementation Plan

## Scope

- Introduce typed event constants via `HexMapWorkspaceEvent` enum + event descriptor registry in `HexMapWorkspaceDispatcher`.
- Ensure dispatch returns separated concerns: `reducer_result`, `side_effects`, `ui_state_update`, and `debug_report_proof`.
- Preserve required envelope keys: `ok`, `error`, `event_id`, `payload`, `root_state`, `view_state`.
- Handle null workspace and unknown event as typed failures with structured output.
- Update tests in `tests/test_editor_plugin.gd` for new schema and regression checks.
- Update queue proof and completion state for `STATE-NEXT-10`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace_dispatcher.gd`
- `tests/test_editor_plugin.gd`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL/`
- `docs/review/autopilot/STATE-NEXT-10_SELF_REVIEW_2026-06-14.md`
- `docs/review/autopilot/STATE-NEXT-10_TEST_RESULT_2026-06-14.md`

## Planned Steps

1. Add typed enum + event descriptor map and resolve route.
2. Replace old string-dispatch logic with handler-based mapping.
3. Return structured dispatch result with explicit sections and snapshots.
4. Update root test function to assert new fields while preserving regression behavior.
5. Add contract test for null workspace and unknown-event result shape.
6. Run `./tools/test.sh`.
7. Update queue status, current pointer, and proof log.
8. Write self-review and test-result docs.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Dispatcher typing | medium | `./tools/test.sh`, event contract assertions in `tests/test_editor_plugin.gd` |
| UI state contract | medium | existing root state/view state assertions retained |
| Queue update | low | queue row status and proof log update |
| Null/unknown dispatch safety | medium | dedicated assertions in `tests/test_editor_plugin.gd` |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- `HexMapWorkspaceDispatcher.dispatch` exposes separated output keys and no silent string miss.
- `tests/test_editor_plugin.gd` uses `reducer_result`, `side_effects`, `ui_state_update`, and `debug_report_proof` assertions.
- Unknown event and null workspace return well-formed structured failures.
- `STATE-NEXT-10` is marked complete with proof entries and next pointer updated.
