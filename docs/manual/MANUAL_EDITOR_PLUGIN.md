# EditorPlugin Manual

Hex Map Kit の EditorPlugin は、エディタ上で `HexMapResource` を生成・保存し、シーン内の `TileMapLayer` へ反映するための Dock と Inspector 拡張を提供します。

## 警告

  - manualは仕様書ではない。
  - 記載する事項はユースケースに基づくものであり、実装した事項に基づくべきではない。
  - ユースケースをサポートするための手順・情報以外を記載しない。

このマニュアルは上記ポリシーを満たしていません。

## 1. 有効化

`project.godot` の `[editor_plugins]` に plugin が登録されていることを確認します。

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

Godot エディタ起動後、Dock に **Hex Map Kit** が表示されます。

## 2. Map Generation Dock

Dock は生成パラメータの変更だけでは `_current_data` を再生成しません。`Generate` ボタンを押したときだけ現在の設定で明示的に再生成し、対象 `TileMapLayer` があれば自動で反映します。

### Generator

`Generator` で生成方式を選びます。

- `Simple`: 独立乱数で壁を置く基本生成
- `Hex-inward Markov mesh model`: 外周から中心へ進む対称生成

### Simple

`Simple` では `Shape` とサイズを指定します。

- `Hexagon`: `Radius`
- `Rectangle`: `Width`, `Height`

生成 API は `HexMapGenerator.generate_hexagon()` または `generate_rectangle()` です。

### Hex-inward Markov Mesh Model

対称生成では `Shape` と `Generation Radius` を指定します。

- `Hexagon`: 対称 toric square の外周側 split 0 / split 7 を除いた hex 領域
- `Square`: non-toric square
- `Torus`: toric square

`Generation Radius` は `map_unit_radius` です。square / torus の一辺は `2 * radius + 1` になります。`Generation Radius = 1 / 2` では安定した参照リングが存在しないため、distribution ではなく `Wall Prob` で直接壁を生成します。

### Distribution

対称生成時は `Dist` で preset を選びます。`Edit` を押すと Distribution Editor が開きます。

Preset は `HexRandomizer.get_preset_names()` の順に表示されます。preset を選んでいる場合は、生成時に preset id を `HexMapGenerator` へ渡します。`.tres` を保存・読み込みした場合は `HexDistribution` resource を custom distribution として渡します。

### 共通パラメータ

- `Wall Prob`: 壁確率。0.00 から 1.00
- `Seed`: 乱数シード
- `Rand`: seed をランダム更新
- `Restore Connectivity`: floor 全体の連結性回復

`Restore Connectivity` が有効な場合、生成後に `HexMapGenerator.restore_connectivity()` が実行されます。`HexVector.zero()` は protected floor として扱われます。
Overlay mode の Markov Mesh では同じ選択肢を Overlay Deductor として使い、生成itemを通行阻害itemとして必要分だけ削除して、Placement Mask のfloor集合の連結性を回復します。

### Overlay Generation

`Overlay` を有効にすると、`Generate` ボタンは `Overlay Generation` になり、ユーザー定義 item key を持つ `HexOverlayData` を生成します。`Overlay` が無効な場合は `Primary Generation` として従来の床・壁 `HexMapData` を生成します。

Overlay generation は Placement Mask Query Rows を現在の Shape / サイズの universe に対して評価し、placement candidates として使います。Query Row が0行の場合はShape universe全体を候補にし、Query Row が1行以上あって結果が空の場合はGenerateを実行しません。

- `Uniform Distribution`: Item Pool の各 row を使って item を配置する
- `Add Item`: Item Pool row を追加する
- `Item Num Limit`: Off の場合は各 row の数値を `Weight` として扱い、`Placement Probability` に従って配置する
- `Item Num Limit`: On の場合は各 row の数値を `Limit` として扱い、`Placement Probability` を非表示にする
- Item Pool row の `Tile` は、その item key を `TileMapLayer` に表示するときの source / atlas coords。`Floor Tile` / `Wall Tile` でDock上部のFloor / Wall tile設定をrowへコピーできる
- `Target Item`: `Markov Mesh` で生成する item key。`Wall` など既存名も入力できる
- `Markov Mesh`: `Target Item` に対して対称 toric item generation を使う
- `Placement Mask`: Source Registry の `HexMapResource` / `HexOverlayResource` item keys から生成候補cellを作る
- `Deductor Floor Source`: `Markov Mesh` かつ `Adjacency Rules` Off のOverlay Deductorで、連結性回復に使うfloor集合をPlacement Maskとは別に指定する。未指定時は、生成後に配置item集合のShape universe内complementをfloor集合として使う
- `Enable Adjacency Reference`: On にすると `Markov Mesh` に切り替え、Reference Items と Adjacency Rules を使う
- `Reference Items`: Primary / current Overlay の item keys から参照cellを作る
- `Neighbor Radius`: Adjacency Reference の参照範囲
- `Adjacency Rules`: `default=0.2;1=0.8;2,1=0.4` のように、参照item近傍数または `近傍数,連結成分数` ごとの確率を指定する。`2,1` は内部では `Vector2i(2, 1)` keyとして正規化される。不正entryはstatusに表示され、有効ruleがない場合はGenerateを実行しない。`Edit` で専用editorを開く
- `Apply Write`: `Clear And Write` または `Add Item`。Primary / Overlay 共通で、`TileMapLayer` をclearするか、既存cellを残して書くかを決める
- `Existing Item`: `Merge Existing` / `Replace Existing` / `Skip Existing`

Source Registry では保存済み `HexMapResource` / `HexOverlayResource` を読み込み、Mask / Reference の Query Row にsourceとして追加できます。Query Row追加時はsourceを選び、row内部ではsource名のラベルと、そのsourceに含まれるItemKeyのcomboで対象を絞ります。各sourceにはresource pathと `Item: cell数` が表示されます。同じ resource path を再読み込みした場合は既存sourceを更新します。sourceをClearすると、そのsourceを参照するQuery Rowも削除されます。

Mask Query Row は `AND` / `OR`、`Contain` / `Exclude`、offset を持ちます。offset は現在値ラベル横の六角形cell panelで操作します。`Query Cell` の `Cell Radius` / `Gap` / `Padding` はQuery Rowのhex cell panel共通の表示サイズ設定です。Mask result は Crop On / Off に関わらず現在のShape / サイズを query universe として評価し、Overlay Generateのcandidate cellsにも使います。source が toric square の場合、offset参照はsource本来の `cyclic_size` でwrapします。Crop On中にMask Query RowまたはShape / サイズを編集するとCrop Offに戻ります。

Overlay mode の `Apply Layer` / `Save As .tres` はCrop状態で動作が変わります。Crop OnではCrop resultをShow Mask / `HexOverlayResource` 保存に使います。Crop OffではSource Registry内のOverlay sourceを表示順でstackし、`Apply Write` / `Existing Item` policyに従ってcurrent overlayへ反映してからApply / Saveします。`Apply Write = Clear And Write` はcurrent overlayを置換し、`TileMapLayer` をclearしてから書きます。`Apply Write = Add Item` はcurrent overlayへ合成し、`TileMapLayer` の既存cellを残して書きます。stack実行後はSource Registryのstatusにsource数、item数、occupied数、policyが表示されます。Generate後の自動applyは同じ `Apply Write` に従ってcurrent overlayをTarget `TileMapLayer` に表示します。Item Pool にある item key は row の `Tile` source / atlas coords を使い、Item Pool にない item key は Dock の `Wall` source / atlas coords を fallback として使います。

`Generate History` を有効にすると、Generate成功時に `.tres` を保存し、保存済みsourceとしてSource Registryへ追加します。Primaryは生成された `HexMapData` 全体、OverlayはApply Policy反映前の生成差分 `HexOverlayData` を保存します。Generate Combination の履歴ファイル名には `overlay-combination` を使います。生成キャンセル時は保存しません。

### Stats

Stats は以下を表示します。

```text
Shape  seed=1201  wall_prob=0.45  cells=48  walls=12  floors=36  connected=yes  Generator Name
```

`connected` は現在の `HexMapData` に対する `HexMapGenerator.is_floor_connected()` の結果です。

### Generation Progress

`Generate` ボタンから開始した生成中は Dock 内の progress UI に進行状況と `Cancel` を表示します。Dock は生成処理の状態を `generation_status()` に保持します。

- `running`: 生成中かどうか
- `cancel_requested`: `Cancel` が押されたかどうか
- `progress`: 0.0 から 1.0
- `status`: `Generating` / `Preparing` / `Updating` / `Ready` / `Cancel requested` / `Cancelled`

生成は Worker Thread で実行され、Core の `interrupt_options` に `progress_callback` / `cancel_callback` / `chunk_size` を渡します。`Generate` ボタンから開始した生成は短時間で完了する場合でも Dock 内 progress を表示し、成功時は最低 0.8 秒は表示してから非表示にします。Dock 内 progress の `Cancel` は cancel request を立て、Core の cancel callback が検出した時点で生成を中断します。Generate flow では modal progress window を作成しません。cancel 時は生成途中の partial data を Dock の current map へ反映せず、最後に完了した map を保持します。

### TileMapLayer Settings

Generate 後の自動 apply と `Apply Layer` で使う TileMapLayer 設定を Dock から指定できます。

| 設定 | 内容 |
|---|---|
| `Target` | Generate 後の自動 apply / `Apply Layer` の apply 先 |
| `Orientation` | `flat-top / Vertical Offset` または `pointy-top / Horizontal Offset` |
| `Tile Size` | `TileSet.tile_size` に設定する width / height |
| `Floor` | floor tile の `source_id`, `atlas_x`, `atlas_y` |
| `Wall` | wall tile の `source_id`, `atlas_x`, `atlas_y` |
| `Apply Write` | `Clear And Write` はApply前に対象 `TileMapLayer` をclearする。`Add Item` は既存cellを残して生成結果を重ね書きする |

`Orientation` は `HexMapResource` に保存されます。Generate 後の自動 apply と `Apply Layer` はこの orientation を正として、対象 `TileMapLayer.tile_set` と `set_cell()` 用の cell 座標を同時に設定します。
`Orientation` を切り替えると、flat-top / pointy-top で横長・縦長が入れ替わる前提に合わせて `Tile Size` の width / height も入れ替えます。

`Target` は常に `Auto: Selected / first scene layer`、scene root 以下の `TileMapLayer`、`Add new layer...` を表示します。通常は Scene Tree と同じ短い node 名で表示し、同名レイヤーが複数ある場合だけ root からの短い相対 path で区別します。`Refresh` は scene 内の `TileMapLayer` を再取得し、Auto 項目を保持します。Target が `Auto` の場合、Generate 後の自動 apply / `Apply Layer` は Editor の選択中 `TileMapLayer`、または scene 内の最初の `TileMapLayer` を使います。

`Add new layer...` を選ぶと、編集中 scene root 直下に新しい `TileMapLayer` を追加し、そのレイヤーを Target と Scene Tree 選択にします。

`Tile Size` / `Floor` / `Wall` の SpinBox と `Orientation` を変更すると、現在の map data を Scene Tree で選択中の `TileMapLayer` に即時 apply します。この即時 apply は Target とは独立です。生成が完了した場合は Target が指すレイヤーへ自動 apply します。atlas coords を変更しながら、選択中 TileMapLayer 上の見た目を確認するための flow です。

TileSet は以下に設定されます。

```text
tile_shape = TILE_SHAPE_HEXAGON
tile_layout = TILE_LAYOUT_STACKED
tile_offset_axis = TILE_OFFSET_AXIS_VERTICAL    # flat-top
tile_offset_axis = TILE_OFFSET_AXIS_HORIZONTAL  # pointy-top
```

TileSet が未設定の `TileMapLayer` へ適用した場合は、新しい `TileSet` を作成してから設定します。
同じ `TileSet` resource を複数 `TileMapLayer` が共有している場合、Dock は設定変更前に選択中レイヤー側の `TileSet` を複製して、他レイヤーへ Tile Size / Orientation / atlas 設定が伝播しないようにします。
`Apply Write = Add Item` のApplyでは、既存 `TileMapLayer` cellは維持され、生成結果があるcellだけが上書きされます。
Apply 後に TileMapLayer Inspector 側だけで `Horizontal Offset` / `Vertical Offset` を手動変更する経路は管理対象外です。

Godot 側の対応 API は公式ドキュメントの `TileMapLayer`、`TileSet`、`TileSetAtlasSource` を参照します。

- https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html
- https://docs.godotengine.org/en/stable/classes/class_tileset.html
- https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html

### Hex Map Edit Document Header

`Hex Map Edit` Dock の document 操作は `New Document` / `Open...` / `Save` / `Save As...` / `Validate` に集約されています。`Document` 表示には selected state、Saved path、Dirty state、Validation summary が表示されます。

`Open...` または `Document Resource` で `HexMapDocumentResource` を選びます。`Save` は保存済み path がある場合に上書き保存し、未保存documentでは `Save As...` と同じ保存先選択になります。`Save As...` は常に保存先を選び直します。

`HexMapResource` から document に変換する場合は Advanced convert の `Convert Resource` / `Browse...` / `Convert` を使います。runtime向け `HexMapResource` を出力する場合は `Export...` / `Export As...` を使います。

### Atlas Image

`Browse Atlas Image` は resource path の画像を読み込み、Scene Tree で選択中の `TileMapLayer.tile_set` または `HexTileMapLayer` の表示用 TileSet に `TileSetAtlasSource` を作成します。source id は Dock の `Floor` source を使い、floor / wall の atlas coords と `Tile Size` を TileSetAtlasSource に反映します。設定後は `Wall` source も同じ source id に同期されます。

`Use Sample Tiles` は addon 同梱の `addons/hex_map_kit/assets/sample_hex_tiles.png` を使うショートカットです。Scene Tree で選択中の `TileMapLayer` に対して、sample は `source_id=0`、floor `Vector2i(0, 0)`、wall `Vector2i(1, 0)`、tile size `64 x 57` に設定します。

`Hex Map Edit` Dock側の `Target TileSet / Atlas` でも、`Browse` から画像を選んでTarget TileSetへ反映できます。`TileSet` ResourcePicker、sample preset、direct path入力は同じTarget TileSetを更新し、documentにはasset pathやTileSet referenceを保存しません。`Target Status` にはTileSet path、source count、tile size、floor / wall / overlay payload、overlay visibilityが表示されます。

### Buttons

- `Generate`: 現在の設定で Primary または Overlay を再生成し、対象 `TileMapLayer` があれば自動 apply
- `Cancel`: 生成中の Dock 内 progress から実行中 generation に cancel request を記録
- `Save As .tres`: Primary mode では `HexMapResource`、Overlay mode では `HexOverlayResource` として保存
- `Apply Layer`: Target の `TileMapLayer`、または Auto 解決先に現在の Primary / Overlay を手動再反映
- `Browse Atlas Image`: 画像 resource を `TileSetAtlasSource` として Scene Tree 選択中 `TileMapLayer` / `HexTileMapLayer` に設定
- `Use Sample Tiles`: addon 同梱 sample atlas を Scene Tree 選択中 `TileMapLayer` に設定

Generate 後の自動 apply と `Apply Layer` は `HexMapTileAdapter.apply_to_tile_map_layer()` を使います。表示するには、対象 `TileMapLayer` の `TileSet` 側に、Dock で指定した floor / wall の source と atlas coords に対応する tile を用意します。

## 3. Distribution Editor

Distribution Editor は `HexDistribution` の 3-neighbor / 2-neighbor / 1-neighbor table を編集します。

### 表示

各 pattern は、参照セルの floor/wall 状態と、中央セルの生成値を表示します。SpinBox の値は 0.0 から 8.0 で、生成確率は `value / 8.0` です。

中央セルの色は以下です。

```text
brightness = 0.9 - value / 10.0
```

値が大きいほど暗く表示されます。

### Preset

Window 起動時は preset の値が SpinBox に入ります。`Preset` を変更すると、現在の編集 path はクリアされ、preset 値が再読み込みされます。

`Duplicate Preset...` は現在表示中の preset 値を新しい custom `.tres` として保存します。保存後はその path が編集中 path になり、`Recent` に追加されます。

### Load / Save

- `Load .tres`: `HexDistribution` resource を読み込み、SpinBox に反映
- `Save New...`: 現在値を新しい `.tres` として保存
- `Apply`: 読み込み済み path へ保存し、Map Generation Dock へ適用
- `Cancel` または window close: 保存せず閉じる

読み込みまたは保存した custom `.tres` は `Recent` に表示されます。`Recent` から path を選ぶと、その custom distribution を再読み込みします。

保存後は FileSystem scan が実行されます。

## 4. HexMapResource Inspector

`HexMapResource` を Inspector で選択すると、先頭に以下の summary が表示されます。

```text
cells=49  walls=20  floors=29  connected=yes  orientation=flat-top  torus=7x7
```

この表示は `resource.to_map_data()` の結果をもとに算出されます。
