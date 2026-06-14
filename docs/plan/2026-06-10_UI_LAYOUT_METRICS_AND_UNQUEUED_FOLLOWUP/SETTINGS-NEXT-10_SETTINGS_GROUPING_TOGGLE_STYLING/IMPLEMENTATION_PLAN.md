# Implementation Plan

## Scope

Separate Settings into Sample Learning, Debug, Project Defaults, and UI Preferences groups, and expose tooltip-backed CheckBox metadata for boolean controls.

## Target Files

- `addons/hex_map_kit/editor/hex_map_settings_screen.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add Settings group row constants/helpers.
2. Group mounted sample/debug controls in `HexMapSampleSettingsPanel`.
3. Add tooltip-backed boolean control snapshot rows.
4. Expose combined group and boolean-control metadata in `settings_screen_snapshot()`.
5. Extend Settings tests for group ids, group separation, CheckBox control type, and tooltip detail.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Sample detail drawer | defer | Covered by `SAMPLE-NEXT-10`. |
| New settings state resource | defer | This slice is UI presentation. |
| Production defaults asset selection | reject | Resources owns production asset slots. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Sample Learning | Grouping hides sample controls or changes sample mode. | Existing Settings workflow plus group assertions. |
| Debug | Debug fallback leaks outside Settings. | Existing debug fallback assertions plus group assertions. |
| Project Defaults | Movement Profile drifts into Settings. | Existing Resources owner assertion. |
| Boolean controls | Tooltip/check metadata missing. | New boolean control assertions. |
| UI metrics | New groups create layout warnings. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `SETTINGS-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Settings snapshot exposes all four groups.
- Boolean controls are CheckBox/toggle style with tooltip detail.
- Existing sample/debug state behavior remains unchanged.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
