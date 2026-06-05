# PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md

## 目的

Hex Map Kitを公開利用しやすいaddonとして整備する。sample project、API reference、package作成手順を揃え、利用者がGodot projectへ導入して動作確認できる状態を作る。

## 現状

- addon本体は `addons/hex_map_kit/` にまとまっている。
- README、manual、algorithm note、debug scene、headless testsは存在する。
- 公開用API reference、sample project、package manifest / packaging scriptは独立していない。
- `plugin.cfg` はversion `0.2.0` を持つ。

## 方針

代表案として、このrepository自体を開発projectとして維持しつつ、公開用artifactを `dist/` に生成する。

sampleは `examples/` にGodot projectとして置き、headless load testで壊れていないことを確認する。API referenceは手書きの安定ドキュメントを `docs/api/` に置き、主要classとresource schemaを説明する。

## 比較事項

### 候補A: repo全体をsample projectとして扱う

- 既存debug sceneをそのまま利用できる。
- addon利用者には開発用tests / review docsが混ざって見える。

代表案にはしない。

### 候補B: `examples/` に最小sample projectを置く

- 利用者が導入後の構成を確認しやすい。
- addonを例projectへコピーまたは参照する仕組みが必要。

採用候補。

### 候補C: packageだけを作り、sampleはdocs内に留める

- 配布は軽い。
- Godot上で即確認できる入口が弱い。

補助案として残す。

## 破壊的変更候補

- READMEの開発者向け説明と利用者向け説明を分ける。
- `docs/manual/` の一部を `docs/api/` と `docs/guides/` へ再配置する。
- addon配布に不要なdebug / tests / review docsをpackageから除外する。
- `plugin.cfg` のauthor / version / descriptionを公開用に更新する。

## Fallback扱い

READMEとmanualだけを公開導線にする状態はfallbackとして扱う。公開用には、動作するsample projectと、package内容を検証するテストを仕様の中心に置く。

debug sceneをsampleの代替にする状態もfallbackである。debug sceneは開発確認用、examplesは利用者向け確認用として分ける。

## 入出力

入力:

- addon source files
- plugin metadata
- sample scene / script
- API reference原稿
- package include / exclude list

出力:

- package zip
- package manifest
- sample projects
- API reference
- README導線
- package / example / API snippet tests

## 出力物

- `examples/basic_runtime/`
- `examples/editor_workflow/`
- `docs/api/`
- `tools/package_addon.sh`
- `dist/hex_map_kit-<version>.zip`
- package manifestまたはfile list

## API reference対象

- `HexVector`
- `HexGrid`
- `HexMapData`
- `HexOverlayData`
- `HexMapGenerator`
- `HexMapResource`
- `HexOverlayResource`
- `HexMapTileAdapter`
- `HexOverlayTileAdapter`
- `HexTileMapLayer`
- `HexDistribution`
- `HexAdjacencyRuleSet`

## テスト方針

- package scriptがaddonに必要なファイルだけを含めることを検証する。
- example projectがheadlessでloadできることを検証する。
- API referenceのGDScript snippetsを可能な範囲でscript test化する。
- sample atlas assetがpackageに含まれることを検証する。

## 完了条件

- 公開用packageを再現可能に作れる。
- sample projectがGodot headlessでロードできる。
- API referenceが主要classとresource schemaを説明する。
- READMEからsetup、sample、API reference、packageの導線が辿れる。
