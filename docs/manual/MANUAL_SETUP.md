# Setup Manual

Hex Map Kit は Godot 4 addon として配置します。

## 1. 配置

利用先 project の `addons/` 以下に `hex_map_kit` を置きます。

```text
res://addons/hex_map_kit/
  plugin.cfg
  plugin.gd
  core/
  adapter/
  editor/
```

## 2. EditorPlugin の有効化

`project.godot` の `[editor_plugins]` に plugin を登録します。

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

Godot エディタを起動し、Project Settings の Plugins で **Hex Map Kit** が有効になっていることを確認します。有効化後、Dock に **Hex Map Kit** が表示されます。

## 3. TileSet の準備

生成結果を `TileMapLayer` に表示する場合、対象 `TileMapLayer` に `TileSet` を設定します。既定の adapter 設定は以下です。

- floor: `source_id=0`, `atlas_coords=Vector2i(0, 0)`
- wall: `source_id=0`, `atlas_coords=Vector2i(1, 0)`

別の atlas を使う場合は、スクリプトから `HexMapTileAdapter.apply_to_tile_map_layer()` または `HexTileMapLayer` の export property で source / atlas を指定します。

## 4. 動作確認

headless test:

```sh
./tools/test.sh
```

debug scene:

```sh
./tools/debug_hex_orientation.sh
./tools/debug_generated_map.sh
```

詳細は `docs/TEST.md` を参照してください。
