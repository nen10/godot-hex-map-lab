# SCREEN-40 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Catalog を tile/object 統合 visual board へ。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/editor/hex_map_catalog_screen.gd
addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd
addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd   # 再利用
tests/test_editor_catalog.gd
```

## 構成（DESIGN-10）
- card grid: tile entry + object entry を統合。各 card = preview(thumbnail/scene) + name + badge。
- inspector: 選択 entry の preview 拡大 / tags / missing。
- raw source_id / atlas_coords → tooltip。
- empty: `[Create Catalog] [Choose Catalog] [Open sample]`。
- sample は別 source 表示。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 統合 | tile/object 別 | 1 board に tile と object card |
| 主役 | list/ラベル | 先頭が card grid |
| raw id | 露出 | source_id/atlas は通常非表示（tooltip） |
| 欠損 | 不明 | missing entry に badge |

## Planned steps
card grid → inspector preview → tooltip/empty/sample → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task SCREEN-40 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: tile/object を1 board / preview / badge。
- E: board が主役、raw id 非表示、sample 分離。
- `./tools/test.sh` green。
