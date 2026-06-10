# Implementation Plan

## Scope

Extract physical construction for key Generate Dock control groups into builder scripts while keeping `HexMapGenDock` as the orchestration/state-binding owner.

## Target Files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_gen_run_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_source_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_output_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Planned Implementation Steps

1. Add builder scripts:
   - run controls and generation progress.
   - source registry controls.
   - output target controls.
   - result/status controls.
2. Update `HexMapGenDock` to call builders, assign returned node references, and connect existing signals.
3. Add component ownership metadata and a `generation_component_owner_rows()` query.
4. Extend editor tests to verify component owner rows and mounted node metadata.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Move generation execution into services | defer | Not required for internal UI component split. |
| Move every builder function out of `HexMapGenDock` | defer | Some config/overlay controls need separate product decisions. |
| Redesign Generate tab layout | defer | Covered by `GEN-NEXT-10`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Run/progress controls | Generate/cancel signal wiring regression. | Existing generation progress tests. |
| Source controls | Browse/reload/clear source registry regression. | Existing source registry tests. |
| Output controls | Preview/document apply/save state regression. | Existing output target tests. |
| Component ownership | Metadata-only drift. | New owner row and mounted metadata assertions. |
| UI metrics | P0 visual regression. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/TEST.md` with `ARCH-NEXT-11` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Key Generate Dock physical control groups are built by component builder scripts.
- `HexMapGenDock` orchestrates state binding and existing handlers.
- Headless tests verify component ownership and mounted metadata.
- `./tools/test.sh` passes.
- UI metric report has P0 failures = 0.
