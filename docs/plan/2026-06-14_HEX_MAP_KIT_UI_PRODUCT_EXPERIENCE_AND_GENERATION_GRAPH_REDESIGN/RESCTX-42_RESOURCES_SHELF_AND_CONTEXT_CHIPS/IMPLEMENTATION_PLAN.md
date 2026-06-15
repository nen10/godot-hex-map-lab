# RESCTX-42 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Resources 資産棚化 + 各 work tab の context chip 化。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/editor/hex_map_resources_screen.gd      # 資産棚 card / readiness 撤去
addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd # context chip 共通部品
addons/hex_map_kit/editor/hex_map_workspace.gd             # 各 work tab 先頭の chip 配線
tests/test_editor_workspace.gd
```

## 構成
- Resources: `Unique to this map` / `Shared project assets` / `Optional` の3群 card。各 card=資産名+status badge。
- primary: `[Create Missing Resources]`（大 CTA）+ `[Save All]`。
- `Readiness Summary` / `Next actions` ラベル列を撤去。
- 各 work tab 先頭: per-tab context chip（DESIGN-10 各タブの chip 定義）。詳細リンク→Resources。
- empty: `[Select a HexTileMap node]` / Start a map CTA。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 資産棚 | ラベル列残存 | Resources 先頭が card 棚、readiness/next-actions 列が無い |
| chip 化 | work tab に row | work tab 先頭が context chip |
| CTA | テキスト | `[Create Missing Resources]` 大 CTA |
| 重複 | Map 二重 | per-tab chip に Map を持たない（global strip と分離） |

## Planned steps
資産棚 → ラベル列撤去/CTA → work tab chip → empty → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task RESCTX-42 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: Unique/Shared/Optional / work tab 先頭 chip。
- E: readiness/next-actions ラベル列撤去、Create missing は大 CTA。
- `./tools/test.sh` green。
