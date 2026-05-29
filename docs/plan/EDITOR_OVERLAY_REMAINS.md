# EDITOR_OVERLAY_REMAINS.md

`MAPDATA_QUERY` と `MULTI_LAYER` のレビューから残った、Editor Dock の Overlay / mapdata query 周辺の主要課題を置く。保存済み `HexMapResource` / `HexOverlayResource` を Source Registry として扱う基礎機能は実装済みであり、この文書は次にテスト可能な機能追加・修正を整理する。

## 1. Mask Query Universe

優先度: 最優先。

目的:

- Mask query を Overlay Generate の candidate cells として使う場合、評価 universe を現在の Shape / サイズに揃える。
- 参照source側は保存済みResourceの座標やtoric wrapを保持しつつ、生成候補にする段階で現在mapの境界と混同しない。

入力:

- Mask Query Rows
- 現在の Shape / サイズ設定
- Source Registry 内の `HexMapResource` / `HexOverlayResource`
- 各rowの `Contain` / `Exclude`、`AND` / `OR`、offset

出力:

- 現在の Shape / サイズ universe 内に制限された Mask query result
- Overlay Generate の candidate cells
- 空結果時の警告と空生成

テスト:

- Crop Off でも `Exclude` の補集合が現在Shape/サイズ外へ広がらない。
- offset後にsource側cellがShape外へ出ても、candidate cellsは現在Shape/サイズ内に制限される。
- toric square sourceはsource本来の `cyclic_size` でoffset参照できる。
- Mask query resultが空の場合、fallbackせず空candidateで生成される。

## 2. Generate History 表示名

目的:

- ユーザー向けのGenerate Historyファイル名では、実装上の `limited` ではなく `combination` を使う。
- アルゴリズム関数名とUI / ファイル名の語彙を分ける。

入力:

- Overlay mode
- `Generate Combination` toggle
- Target item / Item Pool
- Generate History保存ディレクトリ

出力:

- `日時-overlay-combination-主なitem名.tres` 形式の履歴ファイル名
- 保存成功後のSource Registry entry

テスト:

- `Generate Combination` OnのOverlay履歴ファイル名に `overlay-combination` が含まれる。
- Uniform / Markov / Adjacency の既存命名が維持される。
- 保存成功した履歴だけがSource Registryへ追加される。

## 3. Source Registry 可視化と操作フィードバック

目的:

- Source Registryの各sourceについて、resource pathとitem別cell数を確認しやすくする。
- Crop Off / Overlayで合成対象のOverlay sourceがない場合、Dock上で理由を把握できるようにする。

入力:

- Source Registry entries
- `HexMapData` / `HexOverlayData` のitem keys
- Crop On / Off
- Overlay source stack

出力:

- sourceごとの `Item: cell数` 表示またはdetails表示
- resource path表示またはtooltip
- no overlay source時のstatus表示

テスト:

- `HexMapResource` sourceで `Any` / `Floor` / `Wall` のcell数が確認できる。
- `HexOverlayResource` sourceで保存済みitemごとのcell数が確認できる。
- Crop Off / OverlayでOverlay sourceが0件の場合、Apply / Save / current更新が行われず、UI上のstatusで理由が見える。

## 4. Crop Off Source Stack の状態表示

目的:

- Crop Off / Overlay の `Apply Layer` / `Save .tres` が Source Registry のOverlay source stackを合成し、`_current_overlay_data` を更新することをUI上で分かるようにする。
- ~~異なる `cyclic_size` のOverlay sourceが混在する場合の警告をDock上でも確認できるようにする。~~source本来の `cyclic_size` でoffset参照するため不要

入力:

- Source Registry内のOverlay source表示順
- `Apply Write`
- `Existing Item`
- 各Overlay sourceの `cyclic_size`

出力:

- stack対象source数、合成後item数、current overlay更新結果のstatus
- ~~mixed `cyclic_size` warning~~
- Target layerへのApply結果

テスト:

- Crop Off / Overlay Applyでstack resultがcurrent overlayへ反映されたことをstatus表示する。
- `Apply Write = Clear And Write` と `Add Item` の違いがstatusまたはstatsに反映される。
- ~~mixed `cyclic_size` sourceを含むstackで警告が表示され、~~処理結果が既存policyに従う。

## 5. Query Row Offset Control

目的:

- 横長のQuery Rowを整理し、六方向offset操作を再利用しやすいグラフィカルcontrolにする。
- Mask / Reference query以外のhex方向操作にも転用できるUI部品として扱う。


入力:

- 現在rowのoffset
- 六方向button操作
- rowのsource / item key選択

出力:

- 更新されたoffset
- Query Rowの再評価
- Crop On中のMask Query Row編集によるCrop Off連動

テスト:

- 六方向操作でoffsetが更新される。
- Mask Query Rowのoffset変更でCrop Offに戻る。
- Reference Query Rowのoffset変更ではCrop Offに戻らない。
- 狭いDock幅でも主要controlが読める。

### hex方向操作グラフィカルcontrol

#### 参考資料

`addons/hex_map_kit/editor/hex_dist_editor.gd` において、生成セル+3方向セルのグラフィカルな表示が行われている。これはボタンとしての実装ではないが、flat-top用セル図形を使用したボタン配置の位置関係の参考として使用できるかもしれない。pointy-topの場合にも対応が必要なので注意。

ボタンサイズ(セル図形のサイズ)を変更可能とし、そのサイズに連動して、セルの配置・hex方向操作Control全体のサイズを調整する。

## 6. Deductor Floor Source

目的:

- Overlay Deductorが連結性回復に使うfloor集合を、Placement Mask candidate cellsとは独立して指定できるようにする。
- `MULTI_LAYER.md` の「floor cell集合は走査対象と独立に設定できる」という意図をEditor Dockから扱えるようにする。

入力:

- Deductor floor source query
- Placement Mask query
- Overlay Generator = Markov Mesh
- Adjacency Rules Off
- Overlay Deductor mode

出力:

- Deductorに渡すfloor cells
- 生成対象candidate cells
- Deductor適用後のOverlay Data

テスト:

- Placement MaskとDeductor floor sourceが異なる場合、候補セルと連結性回復対象が分離される。
- Deductor floor sourceが空の場合の警告と生成結果が仕様通りになる。
- Adjacency Rules On、Uniform Distribution、Generate CombinationではDeductor floor sourceが生成結果に影響しない。

## 7. Adjacency Rule Set Validation

目的:

- `Adjacency Rules` の不正entryを無視するだけでなく、Editor Dock上で検出して表示する。
- probability rule keyの入力形式を正規化し、`int` / `String` / `Vector2i` の混在を扱いやすくする。

入力:

- Adjacency Rule Set text
- fallback probability
- target item / reference cells

出力:

- normalized rule dictionary
- invalid entry warning
- Generate実行時に使われるrule summary

テスト:

- validな `neighbor_count` ruleと `neighbor_count,component_count` ruleが正規化される。
- invalid entryがDock上に表示される。
- invalid entryがある場合でも、有効ruleとfallbackが仕様通りに使われる。

## 8. Overlay Layout と Tile Selection

目的:

- Overlay controlsを段階的に把握できる配置にする。
- Item Poolのtile指定を数値入力中心から、見て選べる操作へ近づける。

入力:

- Overlay mode
- Generator / policy toggles
- Item Pool rows
- sample atlas / Floor tile / Wall tile設定

出力:

- 折りたたみまたはgroupingされたOverlay sections
- Item Pool tile pickerまたはsample atlas選択
- Floor / Wall tile設定からのcopy操作

テスト:

- Generator modeごとに必要なcontrolだけが有効になる。
- Item Poolのtile設定が保存・再描画後も維持される。
- 未定義itemは既存のWall fallback policyで描画される。

## 9. clear_layer=false の Editor UI

目的:

- Adapter APIにある `clear_layer=false` をEditor Dockから選べるようにし、既存 `TileMapLayer` cellを残した重ね書き運用を可能にする。

入力:

- Apply Layer
- auto apply
- Target `TileMapLayer`
- clear/write mode

出力:

- `clear_layer=true` の置き換えapply
- `clear_layer=false` の重ね書きapply

テスト:

- `clear_layer=true` では既存cellが消えて生成結果だけになる。
- `clear_layer=false` では生成対象cell以外の既存cellが維持される。
- Target選択とScene Tree選択の既存apply先仕様が維持される。
