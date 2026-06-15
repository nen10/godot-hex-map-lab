# GRAPH-14 IMPLEMENTATION_PLAN（pre-execution）

## Scope
`HexGenerationGraphResource` 化（Dictionary 相互変換 + embed）。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/adapter/hex_generation_graph_resource.gd
tests/test_generation_graph_resource.gd
```

## Resource 形
```gdscript
@tool class_name HexGenerationGraphResource extends Resource
@export var nodes: Array          # [{id,type,params,resource_refs}]
@export var edges: Array          # [{from_node,from_port,to_node,to_port}]
@export var promote_targets: Array # [{node_id, role}]（GRAPH-12 の promote 指定）
@export var semantics_snapshot: Dictionary  # embed（任意・RUNTIME 用）
func to_dict() -> Dictionary
static func from_dict(d: Dictionary) -> HexGenerationGraphResource
```

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 無損失 | param 欠落 | 3 node + 2 edge を save/load して `to_dict` 一致 |
| 対称 | 変換非対称 | `from_dict(to_dict(g))` が等価 |
| runner 互換 | runner に渡せない | load 後 `to_dict` を `GRAPH-10` runner で run 成功 |
| embed | snapshot 欠落 | semantics_snapshot を持つ graph を save/load |

## Planned steps
Resource class → to/from_dict → round-trip test。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task GRAPH-14 --head <branch>`

## Planned completion criteria（structural 中心。UI なし）
- S: Dictionary 相互変換 / save-load round-trip / runner 互換。
- `./tools/test.sh` green。
