## MAPDATA_QUERY.md

保存済みの生成マップデータを Editor Dock 内の名前付き query source として保持し、Overlay generation の Placement Mask / Reference source として再利用できるようにする。

主な対象データは以下。

- `HexMapResource`
  - `HexMapData` として復元し、ItemKey は `Any` / `Floor` / `Wall` を扱う。
- `HexOverlayResource`
  - `HexOverlayData` として復元し、保存済み user item key を扱う。

`TileMapLayer` 直接参照によるマップデータ取得や、`TileMapLayer` から生成マップデータを復元する機能は query source の入力に含めない。

## Generate History

マップデータ生成後に、生成結果を `.tres` として自動保存し、保存済み query source として Dock セッション内に追加する。

### 入力

- `Generate History` checkbox
- 保存ディレクトリ
  - checkbox を On にする操作で選択する。
  - 選択をキャンセルした場合、checkbox は Off に戻す。
- 生成結果
  - Primary generation: 生成された `HexMapData` 全体
  - Overlay generation: Apply Policy 反映前の、その Generate で作られた差分 `HexOverlayData`

### 出力

- 保存済み `.tres`
  - Primary: `HexMapResource`
  - Overlay: `HexOverlayResource`
- source registry entry
  - 保存成功時だけ追加する。
  - 生成キャンセル時、生成失敗時、保存失敗時は追加しない。

### ファイル名

ファイル名は以下を含める。

- 作成日時
- 簡潔な実行条件名
- 主な生成 item 名

例: `20260529-153012-overlay-uniform-tree.tres`

ファイル名に使えない文字は安全な文字へ置換し、同名ファイルが存在する場合は suffix を付ける。

## Source Registry

保存済みマップデータを Dock 内で名前付き source として保持する。保持範囲は Dock セッション内とし、source list の永続復元は別計画で扱う。

### Source entry

各 entry は以下の情報を持つ。

- `display_name`
  - resource path のファイル名を基本にする。
  - 同名別pathがある場合は suffix を付ける。
- `resource_path`
  - UI 上の表示または tooltip で確認可能にする。
- `resource_type`
  - `HexMapResource`
  - `HexOverlayResource`
- `data`
  - `HexMapData` または `HexOverlayData`
- `item_keys`
  - `HexMapResource`: `Any` / `Floor` / `Wall`
  - `HexOverlayResource`: `HexOverlayData.item_keys()`

### 操作

- Load
  - `HexMapResource` と `HexOverlayResource` の `.tres` を読み込む。
  - 同じ `resource_path` が既にある場合は、新規追加ではなく既存 entry を reload する。
- Reload
  - `resource_path` から再読み込みし、`data` / `item_keys` / `display_name` を更新する。
- Clear
  - source entry を削除する。
  - その source を参照している Mask / Reference query 行も同時に削除する。

## Query Row Model

既存の一括 `Any Item` / `All Items` 方式を、行ベースの query builder へ変更する。Mask query と Reference query は同じ row model を使う。

### 入力

- Add row combo
  - source registry 内の `source display_name / ItemKey` を選択する。
- query row
  - `operation`: `AND` / `OR`
    - 1行目は無効化する。
    - 2行目以降で有効にする。
  - `match`: `Contain` / `Exclude`
  - `source_id`
  - `item_key`
  - `offset`
    - axial / cube basis 上の `HexVector` として扱う。

### 行操作

- 行追加
- 行削除
- 上下移動
- 六方向近傍ボタンによる offset 変更
  - 押した方向の offset を increment する。
  - 反対方向の offset が正の場合は、押した方向を増やす前に反対方向を decrement する。

### 評価

query は行順に左から評価する。

- `Contain`
  - source の `item_key` cell 集合を使う。
- `Exclude`
  - query universe 内での補集合を使う。
- `AND`
  - 現在結果と行集合の積集合。
- `OR`
  - 現在結果と行集合の和集合。

1行目はその行集合を初期結果にする。

source が toric square の場合、offset 後の参照座標は source 自身の `cyclic_size` で wrap する。非 toric source は wrap しない。

## Mask Crop

Mask query には `Crop` checkbox を追加し、現在の Shape / サイズ設定から query universe を作る。

### Crop universe

Crop On の場合、現在の generation controls から以下を作る。

- Hexagon: 現在 radius の hexagon cells
- Rect: 現在 width / height の rectangle cells
- Square / Torus: 現在 generation radius または toric size に対応する square cells

Crop Off の場合、query result は source 座標をそのまま使う。

### Generate への反映

- Crop On
  - Overlay Generate の candidate cells は crop 済み Mask query result を使う。
- Crop Off
  - Overlay Generate の candidate cells は raw Mask query result を使う。
- Mask query result が空の場合
  - fallback candidates へ置き換えない。
  - 警告を出し、空 candidate のまま生成する。

### 表示

Crop On 後、生成可能な該当 cell 数を表示する。

- `Any` item は count 対象外。
- 重複 cell は1つとして数える。
- count は非 `Any` item cell の union 数とする。

### 連動項目

- Crop On 中に Mask Query Row 領域を編集した場合、Crop Off に戻す。
- Crop On 中に Shape / サイズ設定を変更した場合も、Crop Off に戻す。
- Reference query や生成 item 設定の編集では Crop Off に戻さない。

## Crop Result Apply / Save

Overlay mode のボタン実行は、Crop On/Offで動作を変更する。

- Crop On / Overlay
  - Crop 結果の Mask query result を確認・保存する用途にする。
- Crop Off / Overlay
  - Source Registry 内の `HexOverlayData` source を、registry 表示順の上から順番に合成して Apply / Save する。
- Primary mode
  - 既存 `Apply layer` / `Save .tres` を維持する。

### Crop result data

Crop result は `HexOverlayData` として作成し、保存時は `HexOverlayResource` にする。

- `cells`
  - crop universe 全体。
- `Any`
  - crop universe 全体を item として保持する。
- `Contain` 由来 item
  - query result 内で該当する cell を保持する。
- `Exclude` 由来 item
  - Crop result の item には含めない。

複数 source に同じ `ItemKey` が存在する場合、保存される item key は `source display_name / ItemKey` 形式で prefix し、衝突を避ける。

### Crop Off source stack

Crop Off / Overlay では、Source Registry 内の全 `HexOverlayResource` / `HexOverlayData` entry を対象にする。

- `HexMapResource` source は合成対象外。
- 対象 Overlay source が0件の場合は警告し、Apply / Save / current 更新を行わない。
- 合成順は Source Registry のUI表示順とする。
- 先頭 Overlay source で stack result を初期化する。
- 2件目以降は `HexOverlayData.apply_overlay(source, APPLY_ADD_ITEM, selected_existing_policy)` で重ねる。
- `cyclic_size` は先頭 source を基準にする。
- 異なる `cyclic_size` の source が混在する場合は警告対象として扱う。

stack result は `_current_overlay_data` に反映する。

- `Apply Write = Clear And Write`
  - current overlay を stack result で置き換える。
- `Apply Write = Add Item`
  - current overlay へ stack result を `APPLY_ADD_ITEM` と selected existing policy で反映する。

### Apply layer

- Crop On / Overlay
  - `Show Mask` 相当の動作にする。
  - Crop result の `Any` 以外の cell を対象にする。
  - query作成領域とは独立した単一 tile 設定を使う。
  - 全対象 cell に同一 tile を配置する。
- Crop Off / Overlay
  - Source Registry の stack result を `_current_overlay_data` に反映してから、更新後の `_current_overlay_data` を Target layer へ適用する。
  - tile mapping は既存 Overlay apply と同じく、Item Pool mapping を優先し、未定義 item は Wall tile fallback を使う。

### Save .tres

- Crop On / Overlay
  - 保存対象は Crop result の `HexOverlayResource`。
  - `Exclude` 指定の item key は保存しない。
- Crop Off / Overlay
  - Source Registry の stack result を `_current_overlay_data` に反映してから、更新後の `_current_overlay_data` を `HexOverlayResource` として保存する。

## Test Plan

- Source registry
  - `HexMapResource` と `HexOverlayResource` の `.tres` をLoadできる。
  - 同じ path をLoadすると既存sourceがreloadされる。
  - Clearでsourceと参照query行が削除される。
- Generate History
  - 保存dir選択キャンセルで checkbox がOffに戻る。
  - Generate成功時に `.tres` 保存とsource追加が行われる。
  - Generateキャンセル時に保存されない。
  - Overlay履歴はApply Policy反映前の差分だけを保存する。
- Query
  - 行ごとの左から評価ができる。
  - `Contain` / `Exclude`、`AND` / `OR` が期待通りの集合を返す。
  - 行の上下移動と削除で評価結果が更新される。
  - offset が反映される。
  - toric source の offset 後座標が `cyclic_size` でwrapされる。
- Crop
  - current Shape / サイズで crop される。
  - Crop On の result が Overlay Generate candidate cells に反映される。
  - 空Maskでもfallbackしない。
  - count が非 `Any` item cell の重複除外数になる。
  - Crop On 中の Mask Query Row 編集で Crop Off になる。
  - Crop On 中の Shape / サイズ変更で Crop Off になる。
  - Reference query 編集では Crop Off にならない。
- Crop Apply / Save
  - Crop result に `Any` universe が保存される。
  - source prefix 付き item key が保存される。
  - `Exclude` 由来 item が保存されない。
  - Crop On / Overlay の `Apply layer` が `Show Mask` 相当として非 `Any` cell だけを描画する。
  - Crop On / Overlay の `Save .tres` が Crop result を保存する。
  - Crop Off / Overlay の `Apply layer` が Source Registry stack result を Target layer へ表示する。
  - Crop Off / Overlay の `Save .tres` が stack 反映後の current overlay を保存する。
  - Crop Off stack apply でも Item Pool mapping と Wall fallback が使われる。
- Crop Off source stack
  - Source Registry 内の全 Overlay source だけが上から順に合成され、Primary source は無視される。
  - 先頭 source で stack result を初期化し、2件目以降が selected existing policy に従って merge / replace / skip される。
  - `Apply Write = Clear And Write` は current overlay を stack result で置き換える。
  - `Apply Write = Add Item` は既存 current overlay へ stack result を追加する。
  - Overlay source が0件の場合は Apply / Save / current 更新を行わない。

実装後は `./tools/test.sh` で全体確認する。
