# REPAIR-12 Implementation Plan

## Scope

intermediate output を child node として inspect できるようにするための事前計画。

この文書は実行ログではない。

## target files

想定:

- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_build_screen_full.gd`
- `tests/test_build_graph_canvas.gd`
- `tests/test_hex_tile_map_layer.gd`

## planned implementation steps

1. intermediate output child の parent / naming / metadata contract を決める。
2. Generate 後に selected intermediate output を child node として作る。
3. 同一 source node の child を run replacement する。
4. graph revision change で child を stale 表示する。
5. Apply/Revert が intermediate child を本番 document と混同しないことを証明する。

## dependency / test matrix

| dependency / area | risk | proof / test |
|---|---|---|
| scene ownership | child が target layer 外に出る | parent path test |
| run lifecycle | child 増殖 | rerun child count test |
| document safety | preview が document を汚す | document unchanged until Apply |
| viewport proof | child が見えない | child display cell count |
| stale state | 古い child を最新扱い | graph revision stale test |

## planned completion criteria

- 中間 output child が viewport で確認できる。
- main target layer の document は Result / Apply まで変更されない。
- 再 Generate で child が置換される。
- stale intermediate が UI / snapshot で区別できる。

