# Implementation Plan

## Scope

Extract Catalog entry list/detail/create/validate behavior into a dedicated editor component while preserving existing Workspace and Paint user-facing behavior.

## Target Files

- `addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add `HexMapCatalogEditorComponent` with component owner rows, entry row/detail helpers, validation helpers, preview helpers, and create/assign action helpers.
2. Update `HexMapWorkspace` Catalog snapshot/action methods to call the component and report component owner rows.
3. Update `HexMapEditTool` catalog list/status formatting to delegate to the component while preserving brush selector behavior.
4. Extend editor tests to assert dedicated Catalog owner rows and Paint non-ownership.
5. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
6. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Rich tile/scene preview rendering | defer | Covered by `CAT-NEXT-11`. |
| Full Catalog screen Control subclass | defer | This slice proves behavioral ownership without broad UI churn. |
| Remove Paint selector compatibility helpers | defer/reject for this task | Paint still needs catalog-key consumption for brush payloads. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Catalog validation | Error/warning summaries change shape. | Existing Catalog and Paint validation tests. |
| Entry preview/detail | Atlas/scene/placeholder detail regressions. | Existing Catalog detail assertions. |
| Create actions | Workspace no longer syncs context after component mutation. | Catalog create/open/save/clear tests. |
| Paint brush selectors | Catalog delegation breaks key payloads. | Paint selector payload tests. |
| Ownership proof | Component exists but is not visible in contracts. | New owner row assertions. |
| UI metrics | Visible UI regression. | `./tools/test.sh` metric gate. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `CAT-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Catalog entry list/detail/create/validate behavior is served by `HexMapCatalogEditorComponent`.
- Workspace keeps only screen/context coordination wrappers for Catalog behavior.
- Paint delegates normal catalog helper formatting and continues to consume catalog keys for brush payloads.
- Tests verify Catalog component ownership and Paint non-ownership.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
