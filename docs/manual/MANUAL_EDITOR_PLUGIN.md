# Hex Map Kit Manual

## 目次

- [Hex Map Kit Manual](#hex-map-kit-manual)
  - [目次](#目次)
  - [4. EditorPlugin ガイド](#4-editorplugin-ガイド)
    - [4.2 マップ生成ドック](#42-マップ生成ドック)
      - [操作方法](#操作方法)
      - [形状ごとの動き](#形状ごとの動き)
      - [Stats 表示](#stats-表示)
    - [4.3 生成結果の保存と利用](#43-生成結果の保存と利用)

---


## 4. EditorPlugin ガイド


### 4.2 マップ生成ドック

```
┌─ Hex Map Kit ──────────────────────────────────┐
│ Shape:  [Rectangle ▼]                           │
│ ─────────────────────────────────────────────── │
│ Width:  [8]  Height: [6]                        │
│ ─────────────────────────────────────────────── │
│ Wall Prob: 0.45  [━━━━●━━━━━━━━]                │
│ Seed:  [1201]  [Rand]                           │
│ ─────────────────────────────────────────────── │
│ ☑ Restore Connectivity                          │
│ ─────────────────────────────────────────────── │
│ Rectangle  cells=48  walls=12  floors=36  ...    │
│ ─────────────────────────────────────────────── │
│ [Generate]  [Save .tres]                        │
└─────────────────────────────────────────────────┘
```

#### 操作方法

| 操作 | 説明 |
|---|---|
| **Shape** | マップ形状を選択: Rectangle / Hexagon / Torus |
| **Width / Height** | Rectangle 選択時の幅と高さ (1–64) |
| **Radius** | Hexagon 選択時の半径 (1–20)。セル数は `1 + 3r(r+1)` |
| **Size (odd)** | Torus 選択時の一辺の長さ。`7, 9, 11, 13` から選択 |
| **Wall Prob** | 壁の生成確率 (0.00–1.00)。スライダーで調整 |
| **Seed** | 乱数シード。`Rand` ボタンでランダム化 |
| **Restore Connectivity** | ON で連結性を自動回復。OFF で壁が分断する場合あり |
| **Symmetric Gen** | Torus かつ odd N のときのみ有効。対称生成モードに切替 |
| **Generate** | 現在のパラメータでマップを再生成 |
| **Save .tres** | エディタファイルダイアログで HexMapResource として保存 |

#### 形状ごとの動き

**Rectangle**:
- Width × Height の非トーラス長方形マップを生成
- サイズは任意（1–64）

**Hexagon**:
- 指定 radius の正六角形マップを生成
- 自動的に非トーラス

**Torus**:
- N×N のトーラス正方形マップを生成
- サイズは `7, 9, 11, 13` から選択
- "Symmetric Gen" ON + odd N で対称生成モード
- Stats 表示に `sym-gen` 文字列が追加される

#### Stats 表示

```
Rectangle  seed=1201  wall_prob=0.45  cells=48  walls=12  floors=36  connected=yes
```

生成後、自動的に `connected` 状態が表示されます。対称生成時は末尾に `sym-gen` が付与されます。

### 4.3 生成結果の保存と利用

**Save .tres ボタン**:
1. 生成後、`Save .tres` をクリック
2. 保存先を選択（デフォルト: `hex_map.tres`）
3. 保存後、FileSystem ドックに `.tres` ファイルが表示される

保存された `.tres` は `HexMapResource` です。スクリプトから読み込んで利用:

```gdscript
var resource = load("res://maps/level1.tres")
var data = resource.to_map_data()

# TileMapLayer に描画
HexMapTileAdapter.apply_to_tile_map_layer($TileMapLayer, data, ...)
```

