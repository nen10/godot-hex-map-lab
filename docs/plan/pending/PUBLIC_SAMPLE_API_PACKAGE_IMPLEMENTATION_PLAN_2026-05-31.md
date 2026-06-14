# PUBLIC_SAMPLE_API_PACKAGE_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md`
- 採用案: `examples/` と `docs/api/` を追加し、`tools/package_addon.sh` で `dist/` を生成する。

## 対象ファイル / directory

- `README.md`
- `addons/hex_map_kit/plugin.cfg`
- `examples/basic_runtime/project.godot`
- `examples/basic_runtime/scenes/basic_runtime.tscn`
- `examples/basic_runtime/scripts/basic_runtime.gd`
- `examples/editor_workflow/project.godot`
- `examples/editor_workflow/scenes/editor_workflow.tscn`
- `docs/api/*.md`
- `tools/package_addon.sh`
- `tests/test_package_artifacts.gd` または既存testへの追加
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## 入出力インターフェース

入力:

- `addons/hex_map_kit/plugin.cfg`
- package include / exclude list
- example project files
- API reference source snippets
- Godot headless executable

出力:

- `dist/hex_map_kit-<version>.zip`
- `dist/hex_map_kit-<version>.manifest.txt`
- loadable example projects
- `docs/api/*.md`
- package / example / api tests

## Resource / artifact schema

package artifact:

```text
dist/
  hex_map_kit-<version>.zip
  hex_map_kit-<version>.manifest.txt
```

example project artifact:

```text
examples/<example_name>/
  project.godot
  scenes/
  scripts/
```

API reference artifact:

```text
docs/api/
  CORE_API.md
  GENERATION_API.md
  RESOURCE_API.md
  TILEMAP_API.md
  EDITOR_PLUGIN_API.md
```

## Package構成

### include

```text
addons/hex_map_kit/
  plugin.cfg
  plugin.gd
  core/
  adapter/
  editor/
  assets/
  LICENSE
```

### exclude

```text
docs/
tests/
debug/
tools/
examples/
.godot/
dist/
```

docsやexamplesを同梱するrelease artifactを別途作る場合は、addon zipとは分ける。

## Packaging script

`tools/package_addon.sh` を追加する。

処理:

1. `addons/hex_map_kit/plugin.cfg` からversionを読む。
2. `dist/hex_map_kit-<version>/addons/hex_map_kit/` を作る。
3. include対象をコピーする。
4. exclude対象が混ざっていないことを検証する。
5. zipを作る。
6. file listを `dist/hex_map_kit-<version>.manifest.txt` へ出す。

## Example project計画

### `examples/basic_runtime`

目的:

- addonを有効化したGodot projectで、scriptからmapを生成し、`HexTileMapLayer`へ適用する。

scene:

- root: `Node2D`
- child: `HexTileMapLayer`

script flow:

1. `HexMapGenerator.generate_rectangle()` でmapを作る。
2. `HexMapResource.from_map_data()` でresource化する。
3. `HexTileMapLayer.apply_map()` で表示する。
4. click signalが導入済みならcell highlightする。

### `examples/editor_workflow`

目的:

- EditorPluginを有効化した状態の最低限のsceneを提供する。

scene:

- root: `Node2D`
- child: `TileMapLayer`

含めるもの:

- sample TileSet設定済みscene
- generated map resource fixture
- overlay resource fixture

## API reference計画

`docs/api/` にclass単位の文書を作る。

最小構成:

```text
docs/api/CORE_API.md
docs/api/GENERATION_API.md
docs/api/RESOURCE_API.md
docs/api/TILEMAP_API.md
docs/api/EDITOR_PLUGIN_API.md
```

各文書の項目:

- class / file path
- 主要method
- 入力
- 出力
- resource schema
- short example
- 関連test

## README更新

READMEの開発計画リンクを現在の `docs/plan/` 状態に合わせる。

追加導線:

- Setup
- Examples
- API Reference
- Packaging
- Tests

## テスト計画

### package artifact test

候補:

- shell scriptでmanifestを作り、`tests/test_package_artifacts.gd` でfile listを読む。
- または`tools/package_addon.sh --check` を追加し、`tools/test.sh` から呼ぶ。

検証:

- `plugin.cfg` が含まれる。
- `plugin.gd` が含まれる。
- `core/` `adapter/` `editor/` `assets/sample_hex_tiles.png` が含まれる。
- `docs/` `tests/` `debug/` がaddon zipに含まれない。

### example project load test

Godot headless:

```sh
godot --headless --path examples/basic_runtime --quit --log-file .godot_user/example_basic_runtime.log
godot --headless --path examples/editor_workflow --quit --log-file .godot_user/example_editor_workflow.log
```

`tools/test.sh` にoptionalまたは標準testとして追加する。標準testに入れる場合、実行時間とGodot project import cacheの影響を確認する。

### API snippet test

- `tests/test_api_examples.gd` を追加する。
- docs/apiの代表snippetと同じ呼び出しをGDScript testへ写し、compile / behaviorを固定する。

## 実装手順

1. package include / exclude listを決める。
2. `tools/package_addon.sh` を追加する。
3. package manifest checkを追加する。
4. `examples/basic_runtime` を追加し、headless load testを作る。
5. `examples/editor_workflow` を追加し、headless load testを作る。
6. `docs/api/` の最小5文書を作る。
7. READMEの導線を更新する。
8. `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` に package / example / api test coverage を追記する。`docs/TEST.md` は実行手順が変わる場合だけ更新する。
9. `./tools/test.sh` を実行する。

## 完了判定

- package zipとmanifestが再現可能に生成される。
- examplesがheadless load testで確認される。
- API referenceの主要snippetに対応するscript testがある。
- READMEから公開利用に必要な入口へ辿れる。
