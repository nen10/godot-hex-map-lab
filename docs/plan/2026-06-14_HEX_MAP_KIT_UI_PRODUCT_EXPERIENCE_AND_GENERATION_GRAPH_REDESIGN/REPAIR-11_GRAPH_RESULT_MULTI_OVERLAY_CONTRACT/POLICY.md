# REPAIR-11 Policy

日付: 2026-06-23
状態: Codex implementation-ready

## 採用判断

`Result` node は Build graph の終端 projection bundle であり、契約を次に固定する。

```text
Result
  terrain: terrain                  # required, exactly one incoming edge
  overlay_0: overlay                # optional overlay slot
  overlay_1: overlay                # optional overlay slot
  overlay_2: overlay                # optional overlay slot
```

実装上は、GraphEdit / `HexGenerationGraph` が `to_port` を文字列で扱うため、固定 prefix の numbered ports として表現する。

| concept | exact representation |
|---|---|
| primary terrain input | `to_port == "terrain"` |
| overlay inputs | `to_port` matches `overlay_<index>` |
| allowed overlay slots for this repair | `overlay_0`, `overlay_1`, `overlay_2` |
| overlay order | numeric suffix ascending: `overlay_0`, `overlay_1`, `overlay_2` |
| Result output type | still `HexGenerationPorts.RESULT` |
| Result input type that is forbidden | `HexGenerationPorts.RESULT` is not accepted by any Result input |

この repair では arbitrary dynamic slot add/remove UI は作らない。3本の overlay slots を常時表示することで、Codex 実装を deterministic にし、GraphEdit slot index / save-load / test proof を明確にする。

## 不採用判断

| item | decision | reason |
|---|---|---|
| `Result` input としての `result` | reject | 終端の入れ子化で projection 責務が曖昧になる。`Result -> Result` は type mismatch で invalid。 |
| primary `Compose` | reject for primary | final projection bundle は `Result` に寄せる。`Compose` は既存互換の overlay transform として残してよいが、primary row / acceptance の主体にしない。 |
| overlay の silent merge | reject | 別 layer として inspection / Apply/Revert できない。 |
| unlimited dynamic overlay ports | defer | UI slot add/remove と save/load migration が別 task 相当になる。この repair は `overlay_0..2` の明示 slot に限定する。 |
| thumbnail-only completion | reject | viewport / document projection を証明しない。 |

## Resource / API 境界

| area | owns | must not own |
|---|---|---|
| `HexGenerationNodeTypes` | Result input schema、`_run_result` の bundle output construction | document mutation / viewport apply |
| `HexGenerationGraph` | numbered overlay ports の validation、required terrain、single-edge-per-port invariant | UI slot placement |
| `HexGenerationGraphRunner` | cache に Result bundle を保持すること | overlay layer naming / Apply/Revert policy |
| `HexGenerationResultResource` | `overlay_maps: Array[HexOverlayResource]` と snapshot metadata | legacy-only single overlay semantics |
| `HexGenerationPromote` | generated overlay layer を置換/追加する primitive | Result bundle全体の orchestration |
| `HexMapBuildScreen` | Result bundle を document preview に promote し、viewport report に overlay details を残す | graph node authoring |
| `HexMapBuildGraphCanvas` | `Result` node の `terrain`, `overlay_0..2` slots 表示/接続 | generated document projection |
| `HexMapBuildNodeInspector` | selected Result の overlay input summary 表示 | hidden merge / mutation |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Result terrain input | `terrain` is required and accepts only `terrain` | terrain 無しで成功扱い | graph validation missing terrain test |
| Result overlay inputs | each `overlay_<n>` accepts only `overlay`; all are optional | overlay が接続できない / type mismatch | graph validation and canvas connection tests |
| single incoming per input port | `terrain` and each `overlay_<n>` have at most one incoming edge | later edge silently overwrites earlier edge in `incoming_edges_by_node` | duplicate-input validation test |
| overlay order | ordered by numeric suffix ascending, not by `edges` array order | Generate ごとに順序が変わる | reversed edge insertion run test |
| Result output resource | `overlay_maps` contains N separate resources; `overlay_map` mirrors first overlay only | existing code sees only first overlay / new code loses others | result resource snapshot / runner test |
| document projection | each Result overlay becomes a separate generated overlay layer | only last overlay remains because promote removes generated overlay on each call | build screen promote result report test |
| generated overlay identity | layer ids are deterministic and tied to Result slot order | Apply/Revert cannot inspect layers reliably | document layer id/order assertions |
| item key conflicts | conflicts are reported as warning metadata, not silently merged | two overlays with same item key/cell look like one safe layer | conflict warning unit test |
| Apply/Revert | terrain + all overlay layers are part of snapshot | overlay だけ残る/消える | top generate apply/revert test extended for overlays |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| `Result.overlay_map` legacy mirror | keep as first overlay mirror | existing code/tests may still inspect single overlay field | after all callsites use `overlay_maps` | result with two overlays keeps `overlay_map == overlay_maps[0]` |
| Result with zero overlay | allow | terrain-only graph is valid | none | terrain-only Result test |
| Result missing terrain | invalid | viewport projection の主体がない | none | validation fails / Generate blocked clearly |
| existing `overlay` input name | do not keep as Result input | ambiguous with new numbered slots; fail loudly rather than hide migration | explicit migration task if needed | unknown input port for `overlay` or no primary uses |
| legacy Compose | keep node type but do not route primary proof through it | can still transform two overlays into one overlay; not the final bundle owner | future Merge Overlay design | no new primary Compose acceptance |

## Exact conflict warning contract

Conflict detection is warning-only in this repair. It must not merge, drop, or block overlays.

Two overlay inputs conflict when both contain the same `item_key` on the same hex cell key.

Result metadata must contain:

```gdscript
metadata["overlay_inputs"] = [
  {"port": "overlay_0", "overlay_index": 0, "present": true, "item_count": 3},
  {"port": "overlay_1", "overlay_index": 1, "present": true, "item_count": 2},
]
metadata["overlay_conflicts"] = [
  {
    "item_key": "spawn",
    "cell_key": "0,0,0",
    "ports": ["overlay_0", "overlay_1"],
  },
]
```

If the exact existing cell key helper differs, use the existing `HexVector.key()` string and assert against that helper-generated value, not a hardcoded hand-rolled format.

## completion criteria

- `Result` schema is readable in code as `terrain + overlay_0..overlay_2`.
- `Result` rejects `result` input by type contract; `Result -> Result` is invalid.
- A graph with one terrain and two overlays returns `HexGenerationResultResource.overlay_maps.size() == 2`.
- `HexGenerationResultResource.overlay_map` remains a first-overlay mirror for legacy callsites.
- `HexMapBuildScreen` promotes all Result overlays into separate generated overlay layers in deterministic order.
- Viewport proof includes terrain projection and overlay projection details; cache or thumbnail proof alone is rejected.
