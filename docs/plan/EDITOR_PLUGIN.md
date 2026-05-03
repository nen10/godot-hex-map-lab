# EditorPlugin 実装計画

## 概要

Hex Map Kit を Godot 4 EditorPlugin として提供する。
マップ生成・管理をエディタ上で完結させることを目的とする。

---

## Phase 1: 基盤と生成 (現行APIで実装可能)

### 1.1 plugin.cfg / plugin.gd
- アドオンとしての登録情報
- EditorPlugin エントリポイント
- Dock の追加/削除管理

### 1.2 マップ生成ドック
Godot エディタ下部パネルにドッキングされる生成用UI。

- 形状選択: Rectangle / Hexagon / Torus
- サイズ指定: 形状に応じて動的切替
  - Rectangle: Width, Height
  - Hexagon: Radius
  - Torus: N (9-split 用に odd 推奨)
- 壁確率: スライダー (0.0–1.0)
- Seed: SpinBox + Randomize ボタン
- 連結性回復: toggle
- 対称生成モード: toggle (Torus + odd N のみ有効)
- 生成ボタン: 即時生成
- Stats 表示: cells/walls/floors/connected
- .tres 保存ボタン: HexMapResource をファイルシステムに保存
- EditorInterface 連携

### 1.3 HexMapResource インスペクタ
EditorInspectorPlugin による HexMapResource の専用編集UI。

- マップ形状のテキスト表示
- Wall/Floor カウント
- cyclic_size 表示
- 生成パラメータの表示 (生成時のみ記録)

### 1.4 生成結果のシーン反映 (TileMapLayer 連携)
- 選択中の TileMapLayer に生成結果を適用するボタン
- タイルセット設定ヘルパー
- Node2D 描画モード切替

---

## Phase 2: シーン統合 (現行APIで実装可能)

### 2.1 HexMapNode (カスタムシーンノード)
- Node2D 派生のカスタムノード
- HexMapResource を参照して TileMapLayer 子ノードを自動生成
- flat-top/pointy-top 切替
- タイルセットオーバーライド

### 2.2 HexMapResource のファイルシステムサムネイル
- EditorResourcePreview による .tres ファイルのプレビュー画像生成
- 壁/床の色分け表示

### 2.3 クイックセットアップ
- TileMapLayer 選択 → 右クリック → "Setup Hex Map" でマップ生成ダイアログ表示
- 選択状態から HexMapResource をドラッグ&ドロップで TileMapLayer に適用

### 2.4 デバッグ実行ランチャー
- エディタメニュー "Hex Map / Debug Orientation" で hex_orientation_debug シーン起動
- エディタメニュー "Hex Map / Debug Generated Map" で generated_map_debug シーン起動

---

## Phase 3: 高度な編集 (将来のAPI拡張が必要)

### 3.1 ビジュアルマッププレビュー
- Control ノード上の `_draw()` による Hex グリッド描画
- 生成結果をドック内にリアルタイムプレビュー

### 3.2 WYSIWYG 壁編集
- HexMapLayer 上での壁タイルのペイント/消去操作
- Undo/Redo 対応 (EditorUndoRedoManager)
- 連結性のリアルタイムハイライト

### 3.3 経路可視化
- クリックで2点選択 → 最短経路の表示/更新
- terminal 指向の連結性回復との連携

### 3.4 バッチ生成
- 複数 Seed での一括生成
- サムネイルグリッドでの比較表示
- 良質なマップの自動選別 (連結性スコア等)

### 3.5 インポート/エクスポート
- JSON 形式でのマップ定義エクスポート
- Unity データ形式からのインポート
- TileSet アセットの自動生成

---

## 実装優先度

1. **Phase 1.1 + 1.2** — マップ生成ドック ← 今回実装
2. Phase 1.3 — HexMapResource インスペクタ
3. Phase 1.4 — TileMapLayer 連携
4. Phase 2.1 — HexMapNode
5. 以降順次
