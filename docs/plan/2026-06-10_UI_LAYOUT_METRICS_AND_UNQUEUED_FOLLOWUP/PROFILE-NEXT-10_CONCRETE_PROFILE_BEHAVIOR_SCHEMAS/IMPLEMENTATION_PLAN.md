# Implementation Plan

## Scope

Implement concrete behavior schemas for Validation Rule Suite, Generation Profile, and Export Profile, then expose selected schemas in Validate / QA / Export screen contexts.

## Target Files

- `addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd`
- `addons/hex_map_kit/adapter/hex_generation_profile_resource.gd`
- `addons/hex_map_kit/adapter/hex_export_profile_resource.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add exported typed fields and `behavior_schema()` helpers to the three profile Resource classes.
2. Seed project-created and preset profiles with useful default schema values.
3. Add schema extraction to `_profile_resource_context()` so Validate / QA / Export snapshots expose concrete behavior.
4. Add adapter tests for schema helper output and save/load roundtrip.
5. Extend editor tests for selected and optional missing profile context schema state.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`, record UI metric report path, then update queue proof and pointer.

## Deferred / Rejected Steps

| step | decision | reason |
|---|---|---|
| Full visual profile editor | reject | This task only requires schema and screen connection. |
| Reducer/event ownership | defer | Covered by `STATE-NEXT-10`. |
| Export package build profile | defer | Covered by `EXPORT-NEXT-10`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Resource serialization | Typed schema fields do not persist. | `tests/test_hex_adapter.gd` save/load assertions. |
| Profile screen contexts | Schemas exist but are not connected to editor screens. | `tests/test_editor_plugin.gd` Validate / QA / Export snapshot assertions. |
| Optional profile state | Schema connection accidentally makes profiles required. | Existing and new optional missing assertions. |
| UI metric gate | Screen state changes introduce P0 regressions. | `./tools/test.sh` UI metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `PROFILE-NEXT-10` coverage.
- Add self-review and test-result docs under `docs/review/autopilot/`.

## Planned Completion Criteria

- All three profile Resource classes expose concrete behavior schemas.
- Validate / QA / Export screen snapshots include selected profile schemas.
- Missing optional profiles remain explicit optional missing state.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
