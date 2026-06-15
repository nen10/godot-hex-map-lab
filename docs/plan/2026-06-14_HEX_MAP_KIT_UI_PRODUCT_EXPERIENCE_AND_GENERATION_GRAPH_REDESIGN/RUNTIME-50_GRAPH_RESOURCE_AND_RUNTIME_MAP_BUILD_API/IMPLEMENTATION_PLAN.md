# RUNTIME-50 IMPLEMENTATION_PLAN（pre-execution）

## Scope
graph resource を実行時に build する API。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/generation/hex_map_graph_builder.gd   # build(graph_res, options) -> result
addons/hex_map_kit/adapter/hex_tile_map_layer.gd         # build_from_graph(graph_res, seed) 追加
examples/basic_runtime/runtime_graph_build_sample.gd
tests/test_graph_runtime_build.gd
```

## API

```gdscript
# data 取得
HexMapGraphBuilder.build(graph_res, options := {}) -> { ok, errors, map_data, overlays }
#   options: { seed: int, semantics_override: {...} }
#   runner.run を headless 実行し、promote 指定（graph metadata）に従い terrain/overlay を集約。

# node へ適用
HexTileMapLayer.build_from_graph(graph_res, seed := 0) -> bool
#   build() の結果を自身に load（既存 load 経路を再利用）。
```

## semantics 解決順
1. `options.semantics_override`
2. graph の **embed snapshot**（既定・自己完結）
3. graph の **reference path**（プロジェクト .tres）
4. 無ければ `errors` を返す（runtime で握れる）

## promote 適用（runtime）
- editor の Document 認証は通らない。graph の promote 指定（どの node 出力をどの role へ）を読み、build 結果を terrain/overlay として layer に直接適用。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 再現 | seed 非再現 | 同 graph+seed 2回 build で同一 map |
| variety | seed 効かない | 別 seed で別 map |
| 自己完結 | 外部依存 | embed graph を外部 .tres 無し env で build 成功 |
| 非 editor | editor 依存混入 | runtime path が editor class を参照しない（import/grep 確認） |
| 失敗握り | crash | semantics 解決不能で `errors` を返す（例外でない） |

## Planned steps
builder → layer method → example → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task RUNTIME-50 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: editor 非依存の graph→map headless path / embed 自己完結。
- E: 完全ランダム生成ユースで保存 graph を runtime から build して map が出る（example + test）。
- `./tools/test.sh` green。
