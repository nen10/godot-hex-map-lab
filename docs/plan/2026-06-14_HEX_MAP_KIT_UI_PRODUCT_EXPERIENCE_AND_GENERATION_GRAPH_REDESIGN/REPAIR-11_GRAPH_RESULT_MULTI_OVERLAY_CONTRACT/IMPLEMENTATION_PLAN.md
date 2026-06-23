# REPAIR-11 Implementation Plan

日付: 2026-06-23
状態: Codex implementation-ready

## Scope

Implement the `Result = 1 terrain + N overlay` contract for `N <= 3` explicit overlay slots.

This task must produce working runtime behavior, not only documentation:

- Graph validation accepts `terrain + overlay_0..overlay_2`.
- Result run output stores all overlays separately.
- Build screen preview/project/apply path promotes all Result overlays as separate generated overlay layers.
- Tests prove save/load, runtime, projection, and revert behavior.

## Non-scope

- Do not implement arbitrary dynamic overlay slot UI.
- Do not move the node add row; that belongs to `REPAIR-13A`.
- Do not split Terrain Filter / Overlay Filter; that belongs to `REPAIR-13`.
- Do not implement intermediate output child scene nodes; that belongs to `REPAIR-12`.
- Do not delete or redesign `Compose`; only keep it out of primary proof.

## Target files

Codex may edit only these source/test files unless it records a specific self-review reason:

| file | required changes |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | Result input schema, overlay port helpers, `_run_result` multi-overlay construction, conflict metadata |
| `addons/hex_map_kit/generation/hex_generation_graph.gd` | enforce single incoming edge per input port; keep required `terrain` validation |
| `addons/hex_map_kit/generation/hex_generation_graph_runner.gd` | usually no source change expected; test through existing cache behavior |
| `addons/hex_map_kit/adapter/hex_generation_result_resource.gd` | add exported `overlay_maps`, snapshot fields; keep `overlay_map` mirror |
| `addons/hex_map_kit/generation/hex_generation_promote.gd` | add option to preserve existing generated overlays for multi-overlay Result projection |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Result slots become `terrain`, `overlay_0`, `overlay_1`, `overlay_2`; connection/build graph remains name-based |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | promote all Result overlays; projection report records overlay count/layers/conflicts |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | show Result overlay summary if selected output metadata is available; at minimum expose labels in snapshot/status |
| `addons/hex_map_kit/generation/hex_generation_preset.gd` | update any built-in graph edge from old `overlay` Result port to `overlay_0` |
| `tests/test_generation_graph.gd` | validation tests for required terrain, multi-overlay ports, duplicate input edge rejection, Result->Result rejection |
| `tests/test_generation_graph_resource.gd` | save/load roundtrip for numbered overlay ports |
| `tests/test_graph_runtime_build.gd` or `tests/test_generation_graph_runner_dirty.gd` | runtime Result output has two overlays in deterministic order |
| `tests/test_generation_promote.gd` | Build screen preview/project/apply/revert with two overlays as separate layers |
| `tests/test_build_graph_canvas.gd` | canvas slot/connection proof for Result overlay ports |
| `tests/test_build_screen_full.gd` | only if existing Build screen full-stack assertions need extension |

## Exact implementation steps

### 1. Define Result overlay port helpers

In `hex_generation_node_types.gd`, add constants/helpers near node constants:

```gdscript
const RESULT_TERRAIN_PORT := "terrain"
const RESULT_OVERLAY_PORT_PREFIX := "overlay_"
const RESULT_OVERLAY_PORT_COUNT := 3

static func result_overlay_port_names() -> Array:
  return ["overlay_0", "overlay_1", "overlay_2"]

static func is_result_overlay_port(port_name: String) -> bool:
  return result_overlay_port_names().has(port_name)
```

Use these helpers everywhere possible instead of repeating string literals.

### 2. Change Result node schema

In `HexGenerationNodeTypes.registry()` for `NODE_RESULT`:

- `terrain`: accepts `[HexGenerationPorts.TERRAIN]`, `required: true`.
- `overlay_0`, `overlay_1`, `overlay_2`: accepts `[HexGenerationPorts.OVERLAY]`, `required: false`.
- Remove the old `overlay` input from the primary schema.
- Keep output `HexGenerationPorts.RESULT`.

Acceptance detail:

- A graph with `Result -> Result.terrain` fails because Result output type is `result`, not `terrain`.
- A graph with `Result -> Result.overlay_0` fails because Result output type is `result`, not `overlay`.
- A graph with no `terrain` edge into Result fails with `missing_required_input`.

### 3. Enforce duplicate incoming edge rejection

Current `HexGenerationGraph.validate()` stores one edge per node/port and silently overwrites duplicates. Add validation before assignment:

```gdscript
if incoming_by_node[to_node].has(to_port):
  errors.append(_error("duplicate_input_edge", to_node, edge, "Input port '%s' on node '%s' already has a connection." % [to_port, to_node]))
  continue
incoming_by_node[to_node][to_port] = edge
```

Do not reject multiple overlays across different ports. Reject only two edges targeting the exact same `to_node + to_port`.

### 4. Build multi-overlay Result resource

In `_run_result(inputs, params, context, resource_refs)`:

- Create `HexGenerationResultResource`.
- Promote terrain into `primary_map` only from `inputs["terrain"]`.
- Iterate `result_overlay_port_names()` in order.
- For each input that is `HexOverlayData`, append `HexOverlayResource.from_overlay_data(...)` to `result.overlay_maps`.
- Set `result.overlay_map = result.overlay_maps[0]` if at least one overlay exists; otherwise `null`.
- Populate metadata:
  - `metadata["overlay_inputs"]` list as defined in `POLICY.md`.
  - `metadata["overlay_count"]`.
  - `metadata["overlay_conflicts"]`.

Conflict implementation should inspect each `HexOverlayData.item_keys()` and `item_cells(item_key)`. Use each cell's existing `key()` method.

### 5. Add `overlay_maps` to `HexGenerationResultResource`

In `hex_generation_result_resource.gd`:

- Add `@export var overlay_maps: Array = []`.
  - If Godot typed exported arrays with preload class are already used safely elsewhere, `Array[HexOverlayResourceScript]` is acceptable; otherwise use plain `Array` to avoid parser incompatibility.
- Update `scope_snapshot()` with:
  - `overlay_count`
  - `overlay_maps_present`
  - `overlay_input_summary` from metadata
  - `overlay_conflicts` from metadata
- Keep `overlay_map_present` for legacy proof.

Do not remove or rename `overlay_map`.

### 6. Allow multi-overlay generated layer preservation

Current `HexGenerationPromote._promote_overlay()` removes all generated overlay layers each time, which would make only the last Result overlay remain.

Add an option, e.g.:

```gdscript
var preserve_existing_generated := bool(options.get("preserve_existing_generated", false))
if not preserve_existing_generated:
  _remove_generated_resources(document.overlay_layers, ROLE_OVERLAY)
```

Then Result projection can:

1. Remove existing generated overlay layers once before the loop, or call the first promote without preserve and later promotes with preserve.
2. Add each overlay as a separate layer with deterministic ids:
   - `generated_overlay_0`, `generated_overlay_1`, ...
   - display names `Generated Overlay 1`, `Generated Overlay 2`, ...
   - metadata includes:
     - `graph_node_id`
     - `overlay_index`
     - `result_port`

If adding metadata requires extending `_metadata(role, options)`, copy through safe optional keys:

- `overlay_index`
- `result_port`
- `result_overlay_count`

### 7. Promote all overlays in Build screen Result path

In `hex_map_build_screen.gd` `_promote_result_report(output, node_id, node_entry)`:

- Treat `output.overlay_maps` as source of truth when present.
- Fall back to `[output.overlay_map]` for legacy single-overlay outputs.
- Promote terrain first.
- Promote each overlay in order, each as a separate generated overlay layer.
- `_last_promote_result` must include:

```gdscript
{
  "ok": promoted,
  "written_role": "result",
  "cell_count": total_count,
  "terrain_result": terrain_result,
  "overlay_results": overlay_results,
  "overlay_layer_ids": ["generated_overlay_0", "generated_overlay_1"],
  "overlay_count": overlay_results.size(),
  "overlay_conflicts": output.metadata.get("overlay_conflicts", []),
  "blocked_reason": "" if promoted else "...",
}
```

Keep `overlay_result` as a legacy alias to the first overlay result if helpful for existing tests.

### 8. Include overlay details in viewport projection report

Where `_last_viewport_apply_report` / projection snapshot is built, preserve enough details for proof:

- `result_overlay_count`
- `result_overlay_layer_ids`
- `result_overlay_conflict_count`
- Existing projection success fields remain unchanged.

Do not mark projection success true from these metadata alone; viewport success still depends on document projection / display layer success from REPAIR-10.

### 9. Update canvas Result slots

In `hex_map_build_graph_canvas.gd`:

- Because canvas rows are generated from `input_definitions(node_type).keys()`, the registry schema change should create visible Result rows automatically.
- Ensure input order is deterministic. If `_input_names_for_type()` depends on dictionary key order, sort Result ports explicitly as:

```gdscript
["terrain", "overlay_0", "overlay_1", "overlay_2"]
```

and then use existing order for other node types.

### 10. Update presets and examples

In `hex_generation_preset.gd`, any Result edge currently targeting `"overlay"` must target `"overlay_0"`.

If there are fixture graphs in tests or docs with `"to_port": "overlay"`, update them when they are part of active tests. Do not add migration code unless a failing active test proves a required bundled asset still uses the old port.

### 11. Inspector / snapshot minimal UX

Do not build a large inspector redesign. Minimum acceptable implementation:

- Result selected output snapshot / inspector text exposes:
  - terrain present/missing
  - overlay count
  - overlay ports in order
  - conflict count
- If the existing inspector has no selected-output report path, put the proof into `HexMapBuildScreen.debug_snapshot()` or existing snapshot method and add test coverage there.

## Dependency / test matrix

| dependency / area | risk | required proof / test |
|---|---|---|
| graph validation | Result may accept missing terrain or `result` input | `tests/test_generation_graph.gd`: missing terrain fails; Result->Result fails |
| graph validation duplicate input | two edges to `overlay_0` silently overwrite | duplicate input edge test with `duplicate_input_edge` code |
| graph resource save/load | numbered overlay ports lost or reordered | `tests/test_generation_graph_resource.gd`: `overlay_0` and `overlay_1` roundtrip |
| runner cache | overlay output collapses to one overlay | runtime graph with two item generators asserts `overlay_maps.size() == 2` |
| overlay order | order follows edge insertion rather than port index | add edges in reverse overlay port order; assert `overlay_maps[0]` is `overlay_0` |
| conflict metadata | same item/cell conflict invisible | two overlay sources with same item/cell produce `overlay_conflicts.size() == 1` |
| document projection | promote loop removes previous overlay | Build screen Result preview creates two generated overlay layers |
| viewport preview | metadata success hides failed projection | existing REPAIR-10 projection ok checks still used; extend report only |
| Apply/Revert | revert restores terrain but leaks overlay layers | extend top generate Apply/Revert test for two generated overlay layers |
| canvas UI | Result slots not visible/connectable | canvas test checks slots/named connections for `overlay_0` and `overlay_1` |

## Required tests / commands

Codex must run:

```sh
./tools/test.sh
```

If Godot is unavailable, Codex must record `BLOCKED_BY_TEST_ENV` and include the exact failure output. On this machine, `/Applications/Godot.app/Contents/MacOS/Godot` exists, so a normal run is expected.

Codex should also run a focused subset while iterating if useful:

```sh
GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot ./tools/test.sh
```

## Planned completion criteria

- Result node has required `terrain` plus optional `overlay_0..overlay_2` ports.
- `Result -> Result` and duplicate input edges fail validation.
- Runtime Result output stores multiple separate overlays in deterministic port order.
- Build screen Result preview promotes all Result overlays as separate generated overlay layers.
- Apply/Revert includes those generated overlay layers.
- Tests cover runtime, Resource roundtrip, canvas connection, and Build screen projection.
- Queue/proof docs are updated only for `REPAIR-11`.
