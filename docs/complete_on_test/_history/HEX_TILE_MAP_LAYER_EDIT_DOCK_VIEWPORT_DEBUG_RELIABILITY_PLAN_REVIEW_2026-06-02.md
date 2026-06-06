# HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_PLAN_REVIEW_2026-06-02.md

## 対象

- UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md`
- Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md`
- Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md`
- Review: `docs/review/_history/HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_REVIEW_2026-06-02.md`

## Planning Flow確認

| Step | 文書 | 判定 |
| --- | --- | --- |
| 1. UX の策定 | `HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_UX_2026-06-02.md` | Operation Steps、既存UX干渉、hack扱い、成功条件がある。 |
| 2. 実装方針の作成 | `HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_POLICY_2026-06-02.md` | 複数候補、採用 / 不採用、破壊的変更、fallback、UX escalationがある。 |
| 3. 詳細な実装計画の作成 | `HEX_TILE_MAP_LAYER_EDIT_DOCK_VIEWPORT_DEBUG_RELIABILITY_IMPLEMENTATION_PLAN_2026-06-02.md` | 入力、出力、schema、対象ファイル、Test path、analog test候補がある。 |
| 4. 計画のレビュー | 本文書 | 既存UXとの干渉と実装対象の閉じ方を確認する。 |

## 既存UXとの干渉

### Generation Dock apply

`HexTileMapLayer` の `hex_size` / display coordinate helperをtile sizeに同期すると、Generation Dock apply後の表示・click座標が変わる。これは現状のずれを修正するための変更であり、既存のmap apply UXを壊すものではない。

### Loop display

前面overlay childを追加する場合、loop duplicate tile copy、path、highlight、payload markerの描画順が変わる。既存のloop duplicate tile自体は維持し、overlayは前面feedbackとして扱う。

### Plain `TileMapLayer` target

内部 `TileMapLayer` 除外は `HexTileMapLayer` 配下のinternal childだけを対象にし、scene上のplain `TileMapLayer` targetは維持する。

### UndoRedo

Editor UndoRedo廃止を採用する場合、Godot Editor Undo/Redoでmanual editを戻すUXは削除される。ユーザーはUndoRedoを重要ではないと明示しているため、短期安定策として許容できる。将来必要になった場合はEditorUndoRedoManager adapterを別途実装する。

## 実装対象の閉じ方

今回の計画は、manual editの正規操作を `HexTileMapLayer` target上で成立させることに閉じる。

含める:

- Dock debug copyability
- invalid click stability
- target Auto / internal layer除外
- `HexTileMapLayer` 表示座標とclick hit一致
- foreground overlay feedback
- UndoRedo error除去
- debug fixture / analog test

含めない:

- Object database icon art
- Labelの本格的なtext layout
- Source Registry / Overlay generation UX全般
- Public sample package

## テスト可能性

- Dock control構成、target解決、invalid click後のvalid click、display coordinate roundtripはheadless testで検証できる。
- 実EditorのOutput Dock errorなし、drag selection/copy操作、実viewport上のhighlight前面表示はanalog testで検証する。
- Debug fixture loadは `tests/test_debug_scenes.gd` に接続できる。

## 不足と修正

現時点の計画は、UndoRedoについて「adapter化」と「廃止」の両候補を残している。実装時にはユーザー価値と安定性から、まず廃止または直接apply fallbackを選び、UndoRedo維持は明示的に必要になった場合だけ扱う。

## 判定

Planning Flowとして実装に進める状態にある。
