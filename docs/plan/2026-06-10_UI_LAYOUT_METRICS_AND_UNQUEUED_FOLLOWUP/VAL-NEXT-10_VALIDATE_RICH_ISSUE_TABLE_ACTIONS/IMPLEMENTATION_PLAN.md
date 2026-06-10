# Implementation Plan

## Scope

Add a richer Validate issue table contract and mounted issue text for severity, domain, scope, target, suggestion, and real per-issue focus actions.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Planned Implementation Steps

1. Add `scope`, `target_text`, `suggestion`, and `available_actions` to Validate issue rows.
2. Add `issue_table` snapshot with explicit columns, row count, rows text, and real-action invariant.
3. Update mounted Validate issue rows text to use the rich issue table rows.
4. Extend Validate tests for columns, action metadata, mounted text, workspace missing rows, and cell-scoped row routing.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Placeholder row buttons | reject | Only real per-issue actions are allowed. |
| Validation traversal progress | defer | Covered by `PERF-NEXT-11`. |
| Debug overlay renderer extraction | defer | Covered by `ARCH-NEXT-22`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Workspace asset issue routes | Missing asset rows lose real focus action. | Validate tests inspect actions and selection results. |
| Cell-scoped issues | Paint focus row lacks table target/suggestion. | Validate tests inspect cell-scoped issue row. |
| Mounted rows | Rich table remains snapshot-only. | Mounted text assertion. |
| UI metrics | Rich row text causes layout regressions. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/TEST.md` with `VAL-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Validate snapshot exposes issue table columns and rows.
- Rows expose severity/domain/scope/target/suggestion and real focus action metadata.
- Mounted issue row text includes rich issue table content.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
