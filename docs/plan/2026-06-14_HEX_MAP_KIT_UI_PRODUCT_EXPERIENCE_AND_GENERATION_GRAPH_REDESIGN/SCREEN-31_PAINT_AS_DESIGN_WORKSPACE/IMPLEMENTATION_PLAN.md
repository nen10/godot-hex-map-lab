# SCREEN-31 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Paint dock を DESIGN-10 Paint wireframe へ。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/editor/hex_map_edit_tool.gd      # dock 再構成（brush palette/status、先頭 row 撤去）
addons/hex_map_kit/editor/hex_map_paint_screen.gd   # build_* helper（現状 contract のみ）に palette/status builder 追加
tests/test_editor_paint.gd
```

## 構成（DESIGN-10）
- chips 帯: `Map / Layer(active role) / Brush(catalog key)`
- 作業面: brush palette（catalog key）+ 形状行(single/line/disc/flood)
- status: `Cell: q,r` / `Last edit: painted N cells on <layer>`
- empty: `[Create Level Document] [Choose Level Document]`
- viewport 同期: active layer / selected cell / last edit を edit state から反映

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 先頭 | row が残る | Paint 先頭が brush 作業面（resource row なし） |
| 同期 | viewport とズレ | active layer/cell/last edit が edit と一致 |
| catalog key | 生 id 露出 | brush が catalog key 表示 |
| empty | ラベル列 | 未設定で CTA |

## Planned steps
先頭整理→palette/status→同期→empty→tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task SCREEN-31 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: brush palette / active layer / cell / last edit / viewport 同期。
- E: Paint 先頭が編集面（resource row 無し）、塗ると last edit が出る。
- `./tools/test.sh` green。
