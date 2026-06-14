# Implementation Plan

## Scope

Add lightweight, bounded preview thumbnails for Generate candidates and QA selected seed rows using generated map/overlay/document data.

## Target Files

- `addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
- `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add `HexMapPreviewThumbnail` Control with snapshot builders for map, overlay, document, and unavailable states.
2. Add Generate current candidate thumbnail component and selected seed thumbnail component.
3. Add preview payloads to generation batch result rows and blocked rows.
4. Add QA selected seed thumbnail Control and expose selected/row previews in QA snapshots.
5. Add tests for data-backed preview availability, budget/truncation, no sample fallback, and QA/Generate connection.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| TileSet/PackedScene rendered thumbnails | defer/reject for this task | Data-backed thumbnails meet acceptance without sample fallback. |
| Full QA score table visual layout | defer | Covered by `QA-NEXT-10`. |
| GenerationResultResource/replay API | defer | Covered by `GENPIPE-NEXT-10`. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Generate current data | Thumbnail not refreshed after generation. | Existing Generate output test plus new preview assertions. |
| Batch score rows | Row preview missing or not copied. | Batch runner test asserts row preview payloads. |
| QA screen context | Selected QA preview not connected. | QA screen test asserts selected preview source/seed. |
| Preview budget | Large previews unbounded. | Thumbnail snapshot budget assertions. |
| UI metrics | New controls cause layout regressions. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `GEN-NEXT-11` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Generate current candidate thumbnail is visible and snapshot-backed after generation.
- Generate Seed Lab selected row thumbnail updates from selected row preview.
- QA selected seed thumbnail and score row previews are connected to generated candidate data.
- Preview snapshots state `sample_source == false` and bounded `budget`.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
