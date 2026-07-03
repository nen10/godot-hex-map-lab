# GQM-14 Result Resource Save/Switch — Implementation Plan

## Scope

- Add a clean result-resource construction helper for data-included saved results.
- Add Build screen controls and methods for saving the latest Result output, listing project result assets, and switching selected result assets into the viewport preview.
- Extend focused tests for save/list/switch without graph rerun, field-limited saved resources, and promote/apply/revert continuity.
- Update queue proof and self-review after verification.

## Target Files

- `addons/hex_map_kit/adapter/hex_generation_result_resource.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `tests/test_build_screen_full.gd`
- `tests/test_generation_promote.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md`
- `docs/review/autopilot/GQM-14_RESULT_RESOURCE_SAVE_SWITCH_SELF_REVIEW_2026-07-03.md`

## Planned Implementation Steps

1. Add `HexGenerationResultResource.from_generated_output()` and `field_limited_snapshot()` helpers.
2. Add Build screen result controls: `Results` dropdown, `Save result...`, `Load result`.
3. Save the latest Result node output from `_last_report.cache`, including graph snapshot, seed, and metadata.
4. Load a selected result resource and promote its stored data into the preview document without `run_graph()`.
5. Keep Apply/Revert state shared with existing generated preview.
6. Update snapshots so tests can assert result list shape, selected name, save/load status, and no thumbnail surface.
7. Add tests and run focused suites, then `./tools/test.sh`.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| GQM-02 asset library | Wrong root or kind path | Save path begins with configured `results/` root. |
| GQM-12 result promote | Saved result cannot become document layers | Switch test checks generated terrain/overlay layers and viewport projection. |
| GQM-13 header contract | Header grows unpredictably | Snapshot records updated 7-item header with result actions grouped near Apply/Revert and old controls absent. |
| Result resource field limits | Park fields accidentally written | Resource snapshot test checks score/validation/preview/source fields remain empty/default. |
| No rerun on switch | Saved result load calls graph runner | Test compares run count/cache state before/after load and uses a graph mutation guard. |

## Docs Updates

- Update test creation log only if test responsibilities change.
- `docs/TEST.md` does not need changes unless standard commands change.

## Planned Completion Criteria

- Save result creates a project `results/` resource with generated data included.
- Result list shows saved project result names without thumbnails.
- Loading a saved result projects data immediately and leaves Apply/Revert pending.
- Existing promote path can commit switched saved result data.
- Focused tests and `./tools/test.sh` pass.
