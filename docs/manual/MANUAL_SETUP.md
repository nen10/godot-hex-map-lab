# Hex Map Kit Manual

## 目次

- [Hex Map Kit Manual](#hex-map-kit-manual)
  - [目次](#目次)
  - [1. セットアップ](#1-セットアップ)
    - [プロジェクトへの導入](#プロジェクトへの導入)
  - [4. EditorPlugin ガイド](#4-editorplugin-ガイド)
    - [4.1 有効化](#41-有効化)

---

## 1. セットアップ

### プロジェクトへの導入

`addons/hex_map_kit/` ディレクトリをプロジェクトの `addons/` に配置します。
`project.godot` に以下のセクションが存在することを確認してください:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```


## 4. EditorPlugin ガイド

### 4.1 有効化

1. `project.godot` の `[editor_plugins]` に `"res://addons/hex_map_kit/plugin.cfg"` が登録されていることを確認してください。

   ```ini
   [editor_plugins]
   enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
   ```

2. Godot エディタを起動すると、下部パネル（`DOCK_SLOT_LEFT_BL`）に **Hex Map Kit** ドックが表示されます。

   ドックが表示されない場合は、エディタの **Project > Project Settings > Plugins** タブで Hex Map Kit が有効になっているか確認してください。

