# Implementation Plan

## Scope

Add a Settings sample detail drawer that exposes sample type, dependencies, duplicate target, and learning-use state without injecting samples into production flows.

## Target Files

- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add selected sample id and detail drawer helpers to the sample settings panel.
2. Add a mounted detail label in the Sample Learning group.
3. Add detail metadata to sample action rows and panel snapshots.
4. Expose detail drawer state through Settings workspace snapshot.
5. Extend tests for sample type, dependencies, duplicate target, learning use, mounted detail text, and no production injection.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Preview thumbnails | defer | Existing preview components are separate. |
| Non-catalog duplicate actions | reject | Only catalog duplicate currently creates a complete project copy. |
| Sample production fallback | reject | Sample policy forbids it. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Sample metadata | Detail omits type/dependencies/use. | Sample settings test inspects detail. |
| Duplicate target | Detail does not show project-copy target. | Test checks catalog duplicate target and post-duplicate state. |
| Mounted UI | Detail remains snapshot-only. | Test checks mounted detail text. |
| Production separation | Samples auto-feed Generate/Paint. | Existing sample mode tests remain green. |
| UI metrics | Detail text creates layout warnings. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `SAMPLE-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Sample panel snapshot exposes detail drawer metadata.
- Mounted sample detail text contains type, dependencies, duplicate target, and learning use.
- Duplicate path remains project-owned and updates context only through explicit duplicate action.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
