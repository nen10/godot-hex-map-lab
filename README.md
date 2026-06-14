# godot-hex-map-lab

Godot 4 向けの Hex map generation addon 実験リポジトリ
Hex 座標系・ランダム壁生成・通路生成(連結性回復)処理を GDScriptとして実装、EditorPlugin と実行時ノードから利用できる形に整理しています。

## 主な機能

- Hex 座標 Core
  - `HexVector` / `HexPoint`
  - 6 近傍、L1 ring/disc、toric wrap
  - floor 連結性判定、連結性回復、最短経路
- Map generation
  - rectangle / hexagon / toric square
  - seed 固定の壁生成
  - protected floor と terminal 接続回復
  - toric square の 9 split と外周から中心へ進む対称生成
- Godot 連携
  - `HexMapDocumentResource` による terrain / overlay / object / label / metadata / dependency authoring
  - `HexTileCatalogResource` と catalog key による tile assignment
  - `HexMapResource` による runtime map `.tres` 保存
  - `HexMapTileAdapter` / `HexTileMapLayer` による `TileMapLayer` 反映
  - `HexTileMapLayer` による実行時 helper
  - EditorPlugin の Hex Map Workspace、Resources tab、選択中 HexTileMap の auto-link、Catalog、Layer Stack、Validation、Seed Lab、Distribution Editor
- Debug scene
  - flat-top / pointy-top の配置確認
  - 生成 map、toric domain、9 split、対称生成 overlay の視覚確認

## 使い方

セットアップと利用方法は以下を参照してください。

- `docs/manual/MANUAL_SETUP.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_SCRIPTING.md`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_PACKAGE.md`
- `docs/api/API_REFERENCE.md`

このリポジトリの editor workspace と UI metric gate運用は `docs/manual/MANUAL_WORKFLOW.md` / `docs/manual/MANUAL_EDITOR_PLUGIN.md` / `docs/TEST.md` に記載されており、サンプル運用・デバッグ overlay 境界・PACKAGE ビルドと Export の分離は `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md` と `docs/manual/MANUAL_PACKAGE.md` を参照しています。

Editor authoring starts in **Hex Map Workspace** by selecting a `HexTileMap` scene node and using the `Resources` tab. The production workflow is project asset selection: create or select a Level Document, Tile Catalog, TileSet, Object Database, Label Database, Layer Stack, Movement Profile, Generation Profile, Validation Rule Suite, Export Profile, and Runtime Handoff destination through Resource pickers and FileDialogs. `Resources` auto-links node-owned resources back to the selected `HexTileMap`; Generate can stay `Preview only` or explicitly `Apply to selected Document`. Resource rows use source badges such as `Node`, `Project`, `Document Dependency`, `Manual Override`, `Sample Learning`, and `Missing` to show ownership. Normal tile and object workflows use catalog keys and object keys rather than raw tile source numbers or editable path text. Bundled samples live in Settings / Samples for learning and can be duplicated into project assets when you want to adapt them.

For onboarding, use **Learn with bundled samples** to open Settings / Samples. Sample mode is OFF by default; turning it ON exposes bundled learning candidates while keeping selected project assets primary. `Duplicate sample catalog to project` copies the sample catalog, tile texture, and object scene into project-owned files.

Examples:

- `examples/basic_runtime/`
- `examples/editor_workflow/`

アルゴリズム詳細:

- `docs/algorithm/ALGORITHM_MAP_GENERATION.md`
- `docs/algorithm/ALGORITHM_ADAPTER.md`

## 自動テスト

```sh
./tools/test.sh
```

`tools/test.sh` also runs the addon package manifest check.

複数 test script を並列実行する場合:

```sh
TEST_JOBS=3 ./tools/test.sh
```

Godot の実行ファイルを明示する場合:

```sh
GODOT_BIN=/path/to/Godot ./tools/test.sh
```

テスト対象と手動 debug 実行は `docs/TEST.md` を参照してください。

## Package

Addon-only package artifact:

```sh
./tools/package_addon.sh
```

This writes `dist/hex_map_kit-<version>.zip` and `dist/hex_map_kit-<version>.manifest.txt`. Public upload is a manual release step.

## 開発計画

実装計画とレビュー残件は `docs/plan/` 以下で管理します。

- `docs/plan/TILEMAP_LAYER.md`: `HexTileMapLayer` 周辺の実行時拡張計画

## リポジトリ構成

```text
addons/hex_map_kit/
  core/      Hex 座標、map data、生成、経路、toric 9 split
  adapter/   TileMapLayer / Resource / runtime layer 連携
  editor/    EditorPlugin UI
debug/       視覚確認用 scene
docs/        manual、algorithm note、plan、test note
docs/api/    public API reference
examples/    runtime and editor-workflow samples
tests/       headless Godot test scripts
tools/       test/debug/package 起動 script
```

## License

This repository and the `addons/hex_map_kit/` addon are distributed under the MIT License. See `LICENSE`.
