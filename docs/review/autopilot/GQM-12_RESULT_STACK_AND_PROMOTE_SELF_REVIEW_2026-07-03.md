# GQM-12 Result Stack And Promote Self Review

Task: `GQM-12_RESULT_STACK_AND_PROMOTE`
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: user contract, 2026-07-03

## Execution Summary

Implemented Result as a stack surface on the graph canvas. Connected rows now resolve as substrate, overlay, or unused; unused terrain remains non-blocking and explains that the first terrain is the substrate. Overlay rows expose Up/Down ordering, write policy (`add_item`, `replace_item`, `add_replace`), and row-level Promote.

Result graph edges now carry `write_policy`, and Result run metadata records ordered overlay inputs plus a policy-composed stack signature. The legacy `overlay_map` field still mirrors the first overlay for existing callers; the composed stack is exposed through metadata to avoid breaking that contract.

Build screen row Promote uses the existing `HexGenerationPromote` path. Selected Result nodes no longer expose a duplicate inspector Promote action; the inspector points users to the row Promote buttons.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Added Result row controls, row snapshots/tooltips, overlay reorder, write-policy persistence, row output extraction, and row Promote signal. |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | Disabled duplicate selected-Result Promote action and labeled row Promote as the primary path. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Added `promote_result_row()` and canvas row Promote routing through existing promote/document application flow. |
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | Added Result edge write-policy evaluation and policy-composed overlay stack metadata while preserving legacy `overlay_map`. |
| `addons/hex_map_kit/generation/hex_generation_promote.gd` | Replaced generated overlay rows by stable layer id when row Promote preserves other generated rows; added row metadata. |
| `tests/test_build_graph_canvas.gd` | Added overlay row reorder coverage verifying graph edge and run overlay order. |
| `tests/test_generation_promote.gd` | Added write-policy composition and row substrate/overlay promote coverage; updated selected-Result Promote expectations. |
| `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Recorded the new Result stack test responsibilities. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marked only GQM-12 `COMPLETE`. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md` | Added GQM-12 proof. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Result write policy reflected in composed output | Implemented as `metadata.overlay_stack_cells` and `overlay_stack_item_count`, not by replacing `result.overlay_map`. | Full-suite regression caught the existing REPAIR-11 contract that `overlay_map` mirrors the first overlay. Preserving that field avoids breaking current callers. | None; tests cover both the legacy field and the new composed stack metadata. |
| First standard `./tools/test.sh` run | Failed in `test_hex_adapter.gd` because local Godot import cache for tracked PNG assets was missing. | The tracked images existed, but `.godot/imported` was stale/absent in this worktree. | Regenerated imports with `/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit --path .`; rerun passed. |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Overlay row reorder changes graph connection order | pass | `_test_result_overlay_row_reorder_updates_run_order()` moves the second overlay row up and asserts the built graph edge order changes. |
| Overlay row reorder changes run overlay stack order | pass | Same test asserts Result run metadata `overlay_inputs[0].from_node` follows the moved row. |
| Row write policy affects composition | pass | `_test_result_write_policy_composes_overlay_stack()` asserts `add_item`, `replace_item`, and `add_replace` produce different `overlay_stack_cells`. |
| Row Promote writes terrain layer | pass | `_test_result_row_promote_writes_document_layers()` promotes the substrate row and asserts one generated terrain layer with Result row metadata. |
| Row Promote writes overlay layer | pass | Same test promotes `overlay_1`, asserts stable `generated_overlay_1`, row metadata, selected overlay data, and same-row replacement on repeat promote. |
| Unused terrain remains explicit and non-blocking | pass | Existing Result row coverage still reports extra terrain as unused; row tooltip now explains first-terrain substrate resolution. |
| Existing Build screen Promote path is not duplicated for Result | pass | `_test_build_screen_vertical_slice_promotes_overlay()` asserts selected Result has no inspector Promote, then verifies non-Result generated output can still use the existing promote path. |
| `./tools/test.sh` green | pass | Final standard run exited 0 with run id `20260703-081215-16972`. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Result node rows show `substrate`, `overlay N`, or `unused`, with row-specific controls rather than a thumbnail or generic Result blob. |
| What user can do | pass | Users can reorder overlay rows, choose a write policy per overlay, and promote a specific substrate/overlay row to the document. |
| Chain runs | pass | Headless tests run graph chains through Result row ordering/policy and then promote row outputs into document terrain/overlay layers. |
| Label-heavy but metrics pass | pass | Controls are compact row actions and policy options; workspace metrics report P0 `0`, P1 `0`. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | generated by standard suite | `.godot_user/ui-metrics/20260703-081215-16972/workspace_layout_metrics.md` |
| P0 failures | 0 | Metric report total_p0_failures = 0. |
| P1 issues | 0 | Metric report total_p1_issues = 0. |
| UI metric applicability | regression proof | GQM-12 changes graph canvas and inspector/build-screen controls; row behavior is covered by targeted editor tests. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Named saved Result resources / switching saved results | queued outside this task | GQM-14 owns saved Result resources after GQM-12. |
| Legacy graph load normalization for Result write policy | queued outside this task | GQM-15 owns graph load paths; this task intentionally did not touch them. |
| Header cleanup / Generate unification | queued outside this task | GQM-13 owns Build header changes and was forbidden by this contract. |

## Repair-now Review

No repair-now item remains. The only repair found during verification was the `overlay_map` compatibility regression; it was fixed by preserving `overlay_map = overlay_maps[0]` and moving composed stack proof into Result metadata.

## Test Review

- Focused Godot run: `res://tests/test_build_graph_canvas.gd` passed.
- Focused Godot run: `res://tests/test_generation_promote.gd` passed.
- Focused Godot run: `res://tests/test_generation_graph.gd` passed after the compatibility repair.
- Command: `TEST_JOBS=1 ./tools/test.sh`
- Result: exit 0
- Run id: `20260703-081215-16972`
- Notes: Final run had known non-fatal macOS CA certificate warnings. A first full run failed on missing local Godot import cache for tracked PNG assets; regenerating imports fixed the environment issue and the final run passed.
