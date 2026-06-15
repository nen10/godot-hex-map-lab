# GRAPH-10 IMPLEMENTATION_PLAN（pre-execution）

## Scope

Generation Graph の headless 基盤（model / validation / node passes / Source / runner / tests）。UI・Promote・Resource 化は含まない（`SUB_TASKS.md` Scope 参照）。

## 変更対象ファイル（新規）

```
addons/hex_map_kit/generation/hex_generation_ports.gd
addons/hex_map_kit/generation/hex_generation_graph.gd
addons/hex_map_kit/generation/hex_generation_node_types.gd
addons/hex_map_kit/generation/hex_generation_graph_runner.gd
tests/test_generation_graph.gd
tools/hexq_queue.py
tools/verify_task.py
```
（`tools/test.sh` の test 一覧へ `test_generation_graph.gd` を追加。`docs/TEST.md` に1行追記。）

## データ model（Dictionary）

```gdscript
Graph = { "nodes": { node_id: Node }, "edges": [ Edge ] }
Node  = { "id": String, "type": String, "params": Dictionary, "resource_refs": Dictionary }
Edge  = { "from_node": String, "from_port": String = "out", "to_node": String, "to_port": String }
```
- 各 node type は output port `"out"` を1つ持ち、型は registry が宣言。
- 入力ポートは node type ごとに名前付き（registry の `inputs`）。

## node type registry（inputs / output / run）

`run(inputs: Dictionary, params: Dictionary, context: Dictionary) -> Variant`
inputs = { 入力ポート名: 上流 output }。

| node type | inputs | output | run が呼ぶ core static（根拠） |
|---|---|---|---|
| `source` | （なし） | `terrain` or `overlay`（params.kind） | Resource(`HexMapDocumentResource`/`HexMapResource`/`HexOverlayResource`) 読込→`HexMapData`/`HexOverlayData`。または `context`/`params` 直渡し data。 |
| `shape` | （なし） | `terrain` | `HexMapData.rectangle(w,h,toric)` / `.square(size,toric)` / `.hexagon(radius)`（[map_data:22/36/40](addons/hex_map_kit/core/hex_map_data.gd:22)）|
| `wall_field` | `in: terrain` | `terrain` | `HexMapGenerator.generate_random_walls(cells, wall_probability, seed, protected_floor)`（[generator:216](addons/hex_map_kit/core/hex_map_generator.gd:216)）→ `data.set_walls(walls)`（[map_data:86](addons/hex_map_kit/core/hex_map_data.gd:86)）|
| `connectivity` | `in: terrain`（任意 `terminals: selection`）| `terrain` | `HexMapGenerator.restore_connectivity(data, direction_seed)`（[generator:1101](addons/hex_map_kit/core/hex_map_generator.gd:1101)）/ `_dense`(1105) / `_sparse`(1417) / `restore_terminal_connectivity`(1059) を params.method で選択 |
| `region_filter` | `in: terrain｜overlay` | `selection` | `HexMapData.item_cells("Floor"/"Wall")`（[map_data:94](addons/hex_map_kit/core/hex_map_data.gd:94)）/ `HexOverlayData.query_item_cells(selectors, AND/OR)`（[overlay_data:56](addons/hex_map_kit/core/hex_overlay_data.gd:56)）|
| `item_generator` | `scope: selection` | `overlay` | `HexMapGenerator.generate_random_items(cells, placement_probability, item_pool, seed, blocked)`（[generator:264](addons/hex_map_kit/core/hex_map_generator.gd:264)）/ `generate_limited_items(cells, item_pool, seed, blocked)`（[generator:320](addons/hex_map_kit/core/hex_map_generator.gd:320)）|
| `compose` | `base: overlay`, `add: overlay` | `overlay` | `base.duplicate_data().apply_overlay(add, write_policy, existing_policy)`（[overlay_data:114](addons/hex_map_kit/core/hex_overlay_data.gd:114)）|

注: `shape→wall_field→connectivity` の粒度分割は意図的。複合関数 `generate_rectangle`（shape+wall+connectivity を1関数で実施, [generator:20](addons/hex_map_kit/core/hex_map_generator.gd:20)）は **使わない**（node 連鎖の意味が消えるため）。

## param schema（最小）

- `shape`: `{ shape: "rectangle"|"square"|"hexagon", width, height, size, radius, toric }`
- `wall_field`: `{ wall_probability: float(0..1), seed: int, protected_floor: Array }`
- `connectivity`: `{ method: "default"|"dense"|"sparse"|"terminal", direction_seed: int }`
- `region_filter`: `{ mode: "floor"|"wall"|"query", selectors: Array, op: "or"|"and" }`
- `item_generator`: `{ mode: "weighted"|"limited", placement_probability: float, item_pool: Array, seed: int, blocked: Array }`
- `source`: `{ kind: "document_terrain"|"document_overlay"|"map_resource"|"provided" }`（Resource は `resource_refs`）

## Runner

`run(graph, context) -> { node_id: output }`:
1. `validate(graph)` を呼ぶ。error があれば実行しない。
2. Kahn 法で topo 順を得る（cycle 検出）。
3. 各 node を順に実行：入力ポート名→上流 output を集めて `registry[type].run(inputs, params, context)`。
4. output を `node_id` で cache し最後に返す。

`validate(graph) -> { ok: bool, errors: Array }`（error = `{code, node?, edge?, msg}`）:
- `unknown_node_type` / `dangling_edge` / `type_mismatch` / `cycle` / `missing_required_input`。

## Dependency / Test Matrix

| area | risk | proof / test（`tests/test_generation_graph.gd`） |
|---|---|---|
| 連鎖 terrain | shape→wall→connectivity が繋がらない | run 後 `HexMapData`、`HexMapGenerator.is_floor_connected(out)` = true |
| 連鎖 overlay | filter→itemgen が繋がらない | `shape→region_filter("floor")→item_generator(weighted)` run、overlay items の cell ⊆ selection、floor 上のみ |
| 型検証 | 不正 edge を通す | `terrain→item_generator.scope`（scope は selection 期待）を `validate` が `type_mismatch` で拒否 |
| cycle | 無限ループ | cycle graph を `validate` が `cycle` で拒否 |
| 必須入力 | 未接続で run | `wall_field` の `in` 未接続を `validate` が `missing_required_input` |
| 決定性 | seed 非再現 | 同 graph+seed 2回 run で同一 output |
| reuse | engine 再実装 | node run が core static を呼ぶ（grep / コードレビューで確認、新規生成 loop を書かない） |
| 空入力 | 空 pool / 空 cells で crash | 空 item_pool → 空 overlay、空 graph → 空結果 |

## Planned steps

1. ports → graph(model+validate) → node_types(registry) → runner の順に実装。
2. test を上記マトリクス通りに作成。
3. `tools/test.sh` に `test_generation_graph.gd` を追加、`docs/TEST.md` 追記。

## Test path

- `./tools/test.sh`
- `python3 tools/verify_task.py --task GRAPH-10 --head <branch>`（queue 整合）

## Planned completion criteria（= queue の二層 DoD）

- S: port 4型 / invalid edge・cycle・missing input を validate が検出 / 新 engine 無し（core static 再利用）。
- E(headless): `Shape→Wall→Connectivity` run→連結 `HexMapData`、`Filter→ItemGen` run→selection 限定 `HexOverlayData`。
- `./tools/test.sh` green。
