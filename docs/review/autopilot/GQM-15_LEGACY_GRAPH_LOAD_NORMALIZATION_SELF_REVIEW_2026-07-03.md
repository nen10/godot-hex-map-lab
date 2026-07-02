# Autopilot Self Review

Task: `GQM-15_LEGACY_GRAPH_LOAD_NORMALIZATION`
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: contract-only execution; task packet creation skipped because the user scope allowed only the GQM-15 queue row, proof log, and this self-review.
Optional execution log: none

## Execution Summary

Legacy graph detection is now centralized in `HexGenerationGraphNormalizer.normalize_graph_for_load()`. Editor load/context restore and runtime Map Build consume normalized graph dictionaries when any legacy node type is present, and report the conversion with before/after node and edge counts.

The Simple profile preset now emits a canonical consolidated `terrain_generation -> result` graph directly. It no longer depends on load-time normalization for the default Generate(Simple) path.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_graph_normalizer.gd` | Added legacy detection, load-time normalization report, status text, and source `context` / `provided` preservation. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Normalizes legacy graph resources before canvas restore and surfaces the normalization report/status. |
| `addons/hex_map_kit/editor/hex_map_graph_instantiator.gd` | Reports whether loaded graph resources contain legacy nodes. |
| `addons/hex_map_kit/generation/hex_map_graph_builder.gd` | Normalizes runtime graph resources before validation/run/promote and exposes `normalization_report`. |
| `addons/hex_map_kit/generation/hex_generation_preset.gd` | Replaced legacy Simple profile chain with consolidated Terrain Generation + Result. |
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | Added consolidated terrain source handling for normalized legacy `source(kind=context/provided)` parity. |
| `tests/test_graph_load_context.gd` | Added legacy resource load -> consolidated canvas -> same output regression. |
| `tests/test_graph_runtime_build.gd` | Added runtime legacy resource normalization parity regression. |
| `tests/test_build_screen_full.gd` | Updated Simple preset expectations and parity proof. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Updated GQM-15 status. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Scope listed `hex_generation_graph_normalizer.gd` for robust normalization work. | Also touched `hex_generation_node_types.gd`. | Legacy `source(kind=context)` normalization must execute through consolidated `terrain_generation`; without this, runtime source-context graphs lost their context key. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Editor load paths normalize legacy graph resource/dictionary input before canvas display. | pass | `tests/test_graph_load_context.gd` loads a legacy sample graph resource and asserts the restored canvas graph contains only consolidated node types. |
| Normalization is explicit in status/report. | pass | Build screen load result and visible status contain `Legacy graph normalized to consolidated nodes (n nodes -> m nodes)`, with `normalization_report` counts. |
| Simple preset definition emits consolidated four-type graph directly. | pass | `tests/test_build_screen_full.gd` asserts Simple preset nodes are `terrain_generation` and `result` only. |
| Simple Generate behavior remains equivalent. | pass | `tests/test_build_screen_full.gd` compares consolidated Simple preset Result output against the old legacy chain. |
| Runtime Map Build normalizes legacy input. | pass | `tests/test_graph_runtime_build.gd` builds a legacy resource through `HexMapGraphBuilder.build()` and compares promoted terrain with direct legacy Result output. |
| Standard gate passes. | pass | `./tools/test.sh` exit 0, run id `20260703-080151-6308`. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Loading a legacy graph opens a consolidated-node canvas, not legacy shape/wall/filter nodes, and status states normalization occurred. |
| What user can do | pass | User can load a legacy graph resource, run it, and get the same generated Result as before. |
| (graph task) chain runs | pass | Legacy sample load path runs terrain -> item -> Result after normalization; Simple Generate still promotes Result. |
| Label-heavy but metrics pass | no | Completion is based on graph model shape, run parity, and status/report state, not labels alone. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260703-080151-6308/workspace_layout_metrics.md` |
| P0 failures | `0` | Metric report total P0 failures `0`. |
| P1 issues | `0` | Metric report total P1 issues `0`. |
| UI metric applicability | UI/graph task | Editor load path changes affect graph canvas first impression. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | none | none |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: focused `res://tests/test_graph_load_context.gd`, `res://tests/test_graph_runtime_build.gd`, `res://tests/test_build_screen_full.gd`
- Result: exit 0 for all focused scripts
- Command: `./tools/test.sh`
- Result: exit 0, run id `20260703-080151-6308`
- Notes: the first full run exposed a missing local Godot import cache for `sample_hex_tiles.png`; a headless `--import --quit` pass rebuilt ignored `.godot` artifacts, then the standard gate passed.
