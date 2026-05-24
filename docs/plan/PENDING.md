

### マップのマニュアル編集機能

分類: 仕様分割。

理由:

- 現在の EditorPlugin は生成結果、resource、TileMapLayer、distribution、atlas setup を接続する Dock である。
- マップ形状編集、壁・床・オブジェクトの座標単位 paint、label / object database、Undo / Redo は、Dock の一括生成とは異なる editor tool とデータ schema を必要とする。
- Godot の既存 `TileMapLayer` 編集機能と Hex Map Kit 側 resource 編集機能のどちらを変更主体にするかを決めないと、Undo / Redo と resource 保存の責務が競合する。

テスト可能な分割仕様:

- 入力:
  - selected `HexMapResource`
  - selected editable layer
  - edit mode: shape / wall-floor / floor tile / wall tile / object / label
  - paint target coordinate: `HexVector`
  - tile paint payload: source id + atlas coords
  - object payload: object id + object property dictionary
  - label payload: label id + label text
- 出力:
  - updated `HexMapResource`
  - updated `TileMapLayer`
  - undoable editor command
  - label database resource
  - object database resource
- headless test:
  - wall / floor edit が `HexMapResource` roundtrip 後も維持される
  - tile paint payload が coordinate ごとに保存される
  - label / object payload が coordinate ごとに保存される
  - undo / redo command が resource と TileMapLayer の両方を戻す
- editor workflow test:
  - クリックした hex 座標が Dock の edit mode に従って更新される
  - 保存した `.tres` を再読み込みして同じ編集状態を復元できる

既存実装との接点:

- `HexTileMapLayer.set_wall()` / `set_floor()` は runtime helper として実装済みで、`tests/test_hex_tile_map_layer.gd` が検証する。
- EditorPlugin 上の WYSIWYG paint / database / Undo / Redo は上記の分割仕様を満たす別計画として扱う。
