# SCREEN-32 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Export を 3形態 purpose card へ。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/editor/hex_map_export_screen.gd          # purpose cards builder
addons/hex_map_kit/editor/hex_map_export_workflow_state.gd  # 3形態 + destination
tests/test_editor_distribution.gd
```

## purpose cards（DESIGN-10）
| card | action | 出力 |
|---|---|---|
| Runtime Map Resource | `[Export .tres]` | Document→`HexMapResource` .tres（HexTileMapLayer load） |
| Runtime Scene | `[Create Scene]` | HexTileMapLayer node tree .tscn |
| Generation Graph | `[Export Graph]` | `HexGenerationGraphResource` .tres（RUNTIME-50 build 用）|
| Debug Report / JSON Snapshot | （副次） | 既存 |
| Package | disabled + tooltip | process-only |
頭出し: Runtime Map Resource。empty: `[Build or select a map]`。destination は drawer。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 3形態 | card 欠落 | data/scene/graph の3 card が存在し action する |
| 境界 | gameplay 化 | 出力に gameplay 要素なし |
| package | 機能化 | package card は disabled + tooltip |
| empty | destination のみ | 未設定で CTA |

## Planned steps
cards builder → workflow state 3形態 → empty/destination → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task SCREEN-32 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: 3形態 card + debug/json/package(disabled)。
- E: 目的から選べる / gameplay 化しない。
- `./tools/test.sh` green。
