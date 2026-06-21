# エディタープラグインマニュアル

Hex Map Kit は、ヘックスマップの Level Document を作成、生成、編集、検証し、ランタイム向けに受け渡すための 1 つのエディターワークスペースを提供します。

このマニュアルはユーザー操作の流れを説明します。API の詳細は `docs/api/API_REFERENCE.md`、エンドツーエンドの制作とランタイム受け渡しは `docs/manual/ja/MANUAL_WORKFLOW.md` を参照してください。

フォールバック、デバッグ、サンプル、プロセス境界のルールは `docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md` で管理されています。

## 1. アドオンを有効にする

`project.godot` でプラグインが有効になっていることを確認します。

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

Godot を起動すると、エディターに **Hex Map Workspace** ドックが表示されます。現在のワークスペースは次のタスクタブを使います。

1. `Build`: 生成グラフの編集、実行、出力プレビュー、Level Document への昇格。
2. `Paint`: ブラシによるビューポート編集と手作業の仕上げ。
3. `Catalog`: タイル/シーンエントリの管理とカタログキー検証。
4. `Layers`: 役割別レイヤースタックの設定とドキュメント適用。
5. `Resources`: 正本となるリソース選択と依存関係コンテキスト。
6. `Validate`: issue 一覧、フォーカスアクション、修正候補。
7. `QA`: seed 比較と選択結果の昇格。
8. `Export`: ランタイム受け渡し出力の選択。
9. `Settings`: サンプル学習、デバッグ、レポート設定。

`Generate` は旧マニュアル・内部コードでのレガシー互換名です。現在の UI では `Build` タブが主導線です。旧 Generate パネル（`hex_map_gen_dock.gd`）は非表示の互換コードであり、ユーザーからは見えません。

最初の本番向け通し作業は、選択済み `HexTileMapLayer` から始め、`Resources` -> `Build` -> `Paint` -> `Catalog` -> `Validate` -> `QA` -> `Export` の順に進めます。本番作業はバンドルサンプルではなく、シーンノードとプロジェクト所有のリソーススロットから始めます。

1. Scene ツリーで対象の `HexTileMapLayer` を選択します。Workspace は既定で選択ノードに自動リンクします。
2. `Resources` で、プロジェクトの `HexMapDocumentResource`、Layer Stack、Object Database、Label Database、任意の Movement Profile、各種 Profile Resource を作成または選択します。選択ノード固有の不足リソースは `Create Missing Resources` で作成します。
3. `Build` で Simple Build またはグラフキャンバスを使い、出力をプレビューします。正本にする出力は Level Document へ昇格します。
4. `Paint` で、選択したプロジェクトリソースの terrain/object/label ブラシを使います。必要なタイルやシーンエントリが欠けている場合は `Catalog` に移動します。
5. `Catalog` でプロジェクトの `HexTileCatalogResource` を作成または選択し、`TileSet` を割り当て、tile/scene entry を追加して検証します。
6. `Validate` で issue を確認し、cell/resource/catalog entry にフォーカスして修正候補をたどります。
7. `QA` で seed を比較し、選択した結果をプロジェクトの Level Document に昇格します。
8. `Export` で `HexExportProfileResource` を必要に応じて選択し、FileDialog で明示的な受け渡し先を選びます。
9. 役割別レイヤーの作成や、現在のドキュメントを役割別に反映する必要がある場合は `Layers` を使います。
10. `Settings` の Samples は、学習またはバンドルアセットをプロジェクト所有リソースへ複製する目的だけで使います。

## 2. Resources と Level Document を管理する

terrain、overlay、object、label、zone、metadata、依存関係、ランタイム受け渡しを 1 つの Level Document の関係として管理する場合は `Resources` を使います。

通常の Resources ワークフロー:

- Scene ツリーで `HexTileMapLayer` を選択します。Resources コンテキストには選択ノード、`Auto-link: On`、または未選択状態が表示されます。
- `Level Document` で、Resource picker と `Create New...` FileDialog からプロジェクトの `HexMapDocumentResource` を作成または選択します。
- `Layer Stack` は選択ノードの役割別レイヤーリソースです。
- `Object Database`、`Label Database`、`Movement Profile` は共有または任意の制作データです。
- `Create Missing Resources` は、選択ノード固有の不足リソースを指定フォルダーと prefix で作成します。
- 実アセットができるまでは共有プロジェクトリソースを未選択のままにできます。不足状態はサンプルの自動読み込みではなく、`Resources`、`Catalog`、または検証行への導線として表示されます。

Auto-link が有効な間、選択または作成したノード所有リソースは選択中の `HexTileMapLayer` に書き戻されます。共有リソースは Workspace の asset context に残り、Build、Paint、Validate、QA、Export からタスクに応じて再利用されます。

保存済みリソースパスは読み取り専用の状態表示です。通常のドキュメント操作で編集可能な `res://...` テキストを入力欄として使う設計ではありません。

ランタイム向け `HexMapResource` を作る場合は `Export` タブの Runtime Handoff を使います。これは制作元の `HexMapDocumentResource` を保存する操作とは別です。

### Resource Source Badges

リソース行は source badge で所有者と選択状態を示します。パスや内部詳細は tooltip または debug report に置かれます。

| Badge | 意味 | 通常の操作 |
|---|---|---|
| `Node` | 選択中の `HexTileMapLayer` がこの関係を所有しています。 | `Resources` で作成または選択します。Auto-link 有効時はノードへ書き戻されます。 |
| `Project` | プロジェクトリソースが明示的に選択されています。 | Build、Paint、Validate、QA、Export の本番ソースとして使います。 |
| `Document Dependency` | 選択中の Level Document から共有依存関係が hydrate されています。 | ドキュメントが既に関係を所有しているなら維持します。 |
| `Manual Override` | Workspace の選択が、ドキュメント依存関係を意図的に上書きしています。 | 現在のセッションで使い、正本化する場合はドキュメントへ書き戻します。 |
| `Sample Learning` | バンドルサンプルが学習候補として表示されています。 | 本番用に編集する前にプロジェクトへ複製します。 |
| `Missing` | リソースが選択されていません。 | プロジェクトアセットを作成/選択するか、許容される任意リソースとして未選択のままにします。 |

## 3. Build でマップを作る

主導線は `Build` タブです。グラフキャンバスで Shape、Wall Field、Connectivity、Region Filter、Item Generator、Compose などの生成ノードを接続し、`Generate` を押すとグラフが実行され、結果がシーンのビューポートに自動反映されます。Simple Build は導入用で、同じ生成モデルをプリセットグラフとして扱います。

Build の主な操作:

- `Load Graph`: 既存の生成グラフを読み込みます。
- `Overwrite selected`: 選択中ノード/グラフを上書き対象にします。
- `Generate`: 現在のグラフを実行し、結果をビューポートにプレビュー表示します。
- `Generate (Simple)`: profile から簡易生成を実行し、ビューポートに反映します。
- `Apply`: プレビュー表示中の生成結果を確定し、Level Document に保存します。
- `Revert`: プレビュー表示中の生成結果を破棄し、ひとつ前の状態に戻します。
- ノードインスペクター: 選択中のグラフノードのパラメータを編集可能なコントロール（ドロップダウン、数値入力、チェックボックス）で変更できます。パラメータ変更後、次回 `Generate` で差分ノードのみ再計算されます。
- 接続警告: ノード選択時に、必須入力ポートの未接続や出力タイプの不一致がある場合、インスペクターに警告が表示されます。
- Promote: 選択出力を任意の役割 (terrain/overlay/object) で明示的に Level Document へ昇格します。

旧 Generate パネル（`hex_map_gen_dock.gd`）は非表示のレガシー互換コードであり、通常の操作では使用しません。

表示には `Target`、orientation、tile size、catalog key を選びます。

| Setting | 目的 |
|---|---|
| `Target` | 自動選択または明示的な `TileMapLayer` / `HexTileMapLayer` target |
| `Orientation` | `flat-top / Vertical Offset` または `pointy-top / Horizontal Offset` |
| `Tile Size` | TileSet の tile size |
| `Floor Catalog` | floor 表示に使う catalog key |
| `Wall Catalog` | wall 表示に使う catalog key |
| `Apply Write` | target を先に clear するか、既存セルへ生成セルを追加するか |

通常の制作では catalog entry と target `TileSet` が表示詳細を所有します。numeric source や atlas controls は通常の入力面ではありません。

出力の扱い:

- `Generate` を押すと、グラフの出力が自動的に選択中の HexTileMapLayer の Level Document に書き込まれ、ビューポートにプレビュー表示されます。
- `Apply` ボタンでプレビューを確定します（すでに Document に書き込み済みです）。
- `Revert` ボタンでプレビューを破棄し、Generate 前の状態に戻します。

`HexTileMapLayer` が未選択、または選択ノードに Level Document がない場合、適用パスは理由付きでブロックされます。

## 4. QA で seed を比較する

マップの形状とルールは決まっているが seed を比較したい場合は Seed Lab を使います。

1. `Build` で生成設定を用意します。
2. `QA` の Seed Lab で seed count を指定します。
3. `Run Batch` を実行します。
4. rank、seed、score、validation、preview、promotion 状態を score table で比較します。
5. 行を選択して selected seed preview を更新します。
6. `Promote to Document` で、その seed から canonical document を作成します。

昇格後、Resources の Level Document 関係が更新され、`generation_seed` などの metadata が記録されます。昇格は暗黙保存ではありません。永続化にはドキュメント保存ワークフローを使います。

## 5. Tile Catalog を使う

通常の制作では raw tile source number ではなく catalog key を使います。

Catalog setup:

- `Catalog Resource`: プロジェクトの `HexTileCatalogResource` を作成または選択します。
- `TileSet`: 任意のプロジェクト TileSet resource を catalog に選択します。
- `Scene Entry Resource`: scene-tile entry 用のプロジェクト `PackedScene` を選択します。
- `Add Atlas Entry`: atlas tile entry を catalog に追加します。
- `Add Scene Entry`: 選択中 `PackedScene` を参照する scene entry を追加します。
- `Validate Catalog`: missing TileSet、missing source、invalid atlas coords、missing scene、tag/status issue を表示します。

Catalog entry list は key、type、preview、tag、status を表示します。Paint と生成コントロールは `terrain.floor`、`terrain.wall`、`overlay.treasure` などの catalog key を選びます。`source_id` と `atlas_coords` は catalog entry の内部詳細であり、通常の paint input ではありません。

## 6. Terrain、Object、Label を Paint する

target layer を選び、制作意図に合わせて `Edit Mode` を選択します。

- `Shape`: canonical document cell を作成または削除します。
- `Wall / Floor`: terrain occupancy を切り替えます。
- `Floor Tile`: floor catalog key を割り当てます。
- `Wall Tile`: wall catalog key を割り当てます。
- `Object`: object key で object definition を配置します。
- `Label`: label key で text label を配置します。

ビューポート編集は document と target display を同時に更新します。Undo / Redo は code path 上は document state と表示更新の両方に接続されていますが、視覚的な完全復元は必要に応じて追加確認してください。

### Object Placement

Object mode は typed resource を使います。

- `Object DB`: プロジェクトの `HexObjectDatabaseResource` を作成または選択します。
- definition list: 配置する object key を選択します。
- `Definition Scene`: definition のプロジェクト `PackedScene` を選択します。
- `Placement Properties`: bool、number、string、enum を typed control で編集します。

通常の object placement は raw `object_id` テキストや raw JSON property editing を使いません。

### Labels

Label mode は選択中の label database と label key を使います。Label placement は document に属し、terrain や object と同じ検証導線で確認できます。

## 7. Layer Stack を管理する

1 つの document を複数の役割別レイヤーへ適用する場合は `Layer Stack` を使います。

典型的な workflow:

1. `Standard Authoring` または `Minimal Runtime` template を選びます。
2. role、node name、visible state、locked state、z-index、writable source を確認します。
3. `HexTileMapLayer` target を選択します。
4. `Create Missing Layers` で不足している role layer を追加します。
5. `Apply Document` で現在の document を role ごとに適用します。
6. `Clear Role` で選択 role layer を clear します。

通常の layer stack workflow は `HexTileMapLayer` を target にします。plain `TileMapLayer` への直接適用は advanced/debug route であり、主導線ではありません。

## 8. Validate して issue にフォーカスする

document を runtime-ready と扱う前に `Validate` を使います。

Validation row は domain と severity で整理されます。

- domain: Document、Catalog、Layer、Object、Gameplay、Package。
- severity: Error、Warning、Info。

issue を選択すると次が表示されます。

- cell、catalog entry、dependency、resource などの focus target。
- fix suggestion。
- support/debug に必要な issue details。

Cell issue は対象 cell にフォーカスできます。Catalog issue は catalog entry に移動できます。Resource issue は該当 dependency または選択リソースの owner へ戻します。

## 9. Runtime Handoff を作る

runtime/gameplay code が現在の Level Document または generation graph を必要とする場合は `Export` を使います。

現在の Export タブには 3 つの Godot 向け handoff purpose があります。

1. `Runtime Map Resource (.tres)`: ランタイム向け `HexMapResource` を書き出します。
2. `Runtime Scene (.tscn)`: runtime layer node tree を含む `PackedScene` を作ります。
3. `Generation Graph (.tres)`: runtime Map Build API で実行できる自己完結型の `HexGenerationGraphResource` を保存します。

共通手順:

1. 現在の Level Document または graph context を確認します。
2. 必要に応じて `HexExportProfileResource` を選択します。
3. FileDialog で明示的な destination を選択します。
4. 目的カードの action を実行します。

Export は制作元 document の保存ではありません。`HexMapDocumentResource` の永続化には Resources/document save を使います。Package Build は developer process であり、`tools/package_addon.sh` と `docs/manual/MANUAL_PACKAGE.md` の範囲です。Debug Report は support/diagnostic action です。

## 10. Debug Report をコピーする

authoring や validation の問題を報告する場合は Debug Report を使います。現在の UI では、workspace 全体の report は `Export` の secondary action `Debug Report` からコピーできます。Paint tool 側にも edit debug report の copy path があります。

Report には次が含まれます。

- target status
- last edit details
- save/export details
- validation summary
- support に必要な raw status

通常の制作では簡潔な status と validation rows を使います。Debug report は日常編集ではなく support 用です。

Debug overlay rendering は通常の gameplay rendering から分離されています。

## 11. サンプルを学習用に使う

バンドルサンプルは学習アセットです。`Settings` / Samples で確認するか、sample catalog をプロジェクト所有ファイルへ複製してから本番向けに編集します。

初回 onboarding:

1. `Learn with bundled samples` を押して `Settings` を開きます。
2. 空のプロジェクトアセットから本番プロジェクトを始める場合、sample mode は OFF のままにします。
3. メイン selector に学習候補を表示したい場合は `Show bundled samples in asset selectors` を有効にします。
4. production 用に sample catalog、TileSet texture、object scene を編集する前に `Duplicate To Project` を使います。

Sample mode が ON でも、選択済みプロジェクトアセットは上書きされません。Build と Paint はバンドルサンプルを production fallback として自動利用しません。sample を適用する前に project path へ複製してください。

含まれる sample atlas:

```text
res://addons/hex_map_kit/assets/sample_hex_tiles.png
```

sample catalog と object scene:

```text
res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres
res://addons/hex_map_kit/assets/sample_spawn_marker.tscn
```

sample setup は次の数値を使います。

- source id `0`
- floor atlas coords `Vector2i(0, 0)`
- wall atlas coords `Vector2i(1, 0)`
- tile size `64 x 57`

これらの数値は sample asset の詳細です。通常の workflow では、生成、paint、overlay tile に catalog key を選択します。

## 12. Distribution Editor

対称生成の Markov Mesh ルールを調整する場合は、旧 Generate 補助パネルの `Markov Mesh Rule Set` で preset を選び、`Edit` から Distribution Editor を開きます。

Distribution Editor の action:

- `Load .tres`: `HexDistribution` resource を読み込みます。
- `Save New...`: 現在値を新しい resource に保存します。
- `Apply`: 現在 resource を保存し、Generate に適用します。
- `Duplicate Preset...`: preset を custom editable resource へ複製します。

Distribution value は `0.0` から `8.0` の generator weight です。確率としては `value / 8.0` に相当します。

## 13. Reference

- Workflow: `docs/manual/ja/MANUAL_WORKFLOW.md`
- English workflow: `docs/manual/MANUAL_WORKFLOW.md`
- Scripting: `docs/manual/MANUAL_SCRIPTING.md`
- API: `docs/api/API_REFERENCE.md`
- Test execution and debug helper commands: `docs/TEST.md`
- Test design policy: `docs/policy/TEST_DESIGN_POLICY.md`
