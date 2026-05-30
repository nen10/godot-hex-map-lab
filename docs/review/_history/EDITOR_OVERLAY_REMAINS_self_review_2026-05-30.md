# EDITOR_OVERLAY_REMAINS 実装セルフレビュー (2026-05-30)

## Scope

この文書は `docs/plan/EDITOR_OVERLAY_REMAINS.md` の実装差分を、実装者視点で再確認するためのレビューである。主対象は以下の完了済み項目と、それに続くレイアウト調整差分である。

- Mask Query Universe
- Generate History 表示名
- Source Registry 可視化と操作フィードバック
- Crop Off Source Stack の状態表示
- Query Row Offset Control
- Deductor Floor Source
- Adjacency Rule Set Validation
- Overlay Layout と Tile Selection
- `clear_layer=false` の Editor UI
- `HexMapResource` / `HexOverlayResource` の `@tool` 化
- Dock root の `ScrollContainer` 化

確認時点では、`EDITOR_OVERLAY_REMAINS` 主実装は staged 差分、`HexMapResource` / `HexOverlayResource` の `@tool` 追加と Dock root の `ScrollContainer` 化は未staged差分として存在する。ユーザー調整を巻き戻さない前提で、未staged差分もレビュー対象に含める。

実装時の確認として `./tools/test.sh` は通過済みであり、各完了済み仕様は `docs/complete_on_test/EDITOR_OVERLAY_REMAINS_2026-05-30_*.md` と `docs/TEST.md` に記録されている。

## Overall Assessment

今回の実装は、レビューで主要課題として残っていた Editor Dock の Overlay / query 操作を、テスト可能な単位に分けておおむね完了している。特に Mask query universe の現在Shape制限、Source Registry detail表示、Crop Off source stack status、Deductor Floor Source、Adjacency Rule validation は、既存レビューの懸念を実装とテストの両方で回収している。

一方で、いくつかの変更は「仕様として妥当だが、明文化または追加判断が必要」な状態にある。大きいものは `HexAdjacencyRuleSet.parse_rules_text()` の互換性、Deductor Floor Source の空結果 semantics、Editor実機上のレイアウト検証、Status表示の責務分離である。

## Review Findings

### Finding-01: `parse_rules_text()` の戻り値互換性

`HexAdjacencyRuleSet.parse_rules_text()` は `2,1` 形式の rule key を `Vector2i(2, 1)` に正規化するようになった。Core generator は `Vector2i` と legacy string key の両方を受けられるため内部生成は問題ないが、外部スクリプトが `parse_rules_text()` の戻り値を直接参照して `"2,1"` key を期待している場合は互換性が変わる。

また、以前は数値化できない key が文字列として残りうる実装だったが、現在は `default`、整数、`整数,整数` 以外を invalid entry として扱う。Editor入力としては妥当だが、public API としては挙動変更である。

### Finding-02: Dock と Adjacency Rule Editor の fallback 表示が一致しない可能性

Dock の Adjacency Rules status は Wall Probability を fallback probability として解釈する。一方、`HexAdjacencyRuleEditor` 側の validation status は fallback `0.0` で表示する。Editorで表示される `fallback default` の値と、Dockで実際に生成に使われる fallback が異なる可能性がある。

生成自体はDock側で再parseされるため破綻しないが、status textの意味が場所によって少し変わる。

### Finding-03: Deductor Floor Source の空結果を空集合のまま渡す仕様

Deductor Floor Source query result が空の場合、現在の実装は警告を出し、fallbackせず空floor集合を `deduct_items_for_connectivity()` に渡す。これは「空結果をfallbackしない」という最近のMask方針と整合している。

ただし、Deductorの入力として空floor集合を渡すことが「何もしない」「全て削除しない」「期待と違う削除になる」のどれに近い体験になるかは、生成条件によって直感的でない可能性がある。仕様としては完了済みだが、ユーザー向けの意図確認が残る。

### Finding-04: Deductor Floor Source query universe は現在Shapeではなくsource由来

Mask query は Crop On / Off に関わらず現在Shape / サイズを universe として評価するよう整理された。一方で Deductor Floor Source は Reference query と同様に source由来の座標集合を universe として扱う。

これは「連結性回復用floor集合をPlacement Maskとは独立に指定する」目的には合うが、現在Shape外のsource cellがDeductor floor集合に入りうる。candidate cellsとは分離されているため生成対象が広がるわけではないが、Deductorの判断材料としてShape外cellを含めることを仕様として認めるかは確認したい。

### Finding-05: Snapshot作成時のUI status更新

`_create_generation_snapshot()` は Overlay mode で Deductor Floor Source cells と Adjacency Rules を解決し、その過程で status label も更新する。現在のDock実装では既存パターンに近いが、snapshot作成が純粋なデータ作成ではなくUI副作用を持つ。

テスト上は問題ないが、将来 snapshot をheadless helperやpreview処理で再利用する場合は、副作用を分けた方が扱いやすい。

### Finding-06: Source Registry status の責務が多い

`_source_registry_status_label` は以下を兼ねている。

- source件数
- empty state
- no overlay source warning
- Crop Off source stack result
- write / existing policy summary

単一labelなので、source list refresh によって直前のstack resultが上書きされることがある。現状は致命的ではないが、操作結果statusとsource一覧statusを分離した方が、ユーザーが直前操作の結果を追いやすい。

### Finding-07: `Clear Layer` の適用範囲が広い

`Clear Layer` checkbox は Primary apply、Overlay apply、Crop result apply で使われる。これにより `Apply Layer` だけでなく、Generate後の自動applyやCrop result表示でも既存cellを残せる。

デフォルトOnなので従来挙動は維持される。ただし、ユーザーが「通常のApply Layerだけ重ね書きしたい」と考える場合、auto applyにも同じ設定が効くことは明示しておく必要がある。

### Finding-08: Tile Selection はcopy操作であり、実体はまだpickerではない

Item Pool row に `Floor Tile` / `Wall Tile` copy buttonを追加したことで、数値入力だけに依存しないflowにはなった。これは小さく安全な改善で、テストもしやすい。

一方で、現在のUIは「見て選ぶtile picker」そのものではない。TileSetのsource / atlas一覧から選ぶ体験やpreviewはまだ無いので、ユーザー要望が視覚的pickerを意味するなら次の改善対象になる。

### Finding-09: Query Row Offset Control は専用部品化の前段階

六方向buttonを3列gridに移し、横長問題は軽減された。`Direction Size` も導入され、Mask / Reference / Deductor Floorで共有される。

ただし、まだ通常Buttonの配置であり、`hex_dist_editor.gd` のようなhex形状描画controlではない。Dock実機の幅、スクロール、折り返し、label視認性はheadless testでは十分に確認できない。

### Finding-10: `@tool` 化されたResource scriptのEditor実機検証

`HexMapResource` / `HexOverlayResource` に `@tool` が追加されている。`HexMapResource Inspector` やEditor上のResource操作を考えると自然な変更であり、script自体に副作用は少ない。

ただし、headless testはResource roundtripを確認している一方、Inspector上で `.tres` を選択した時の表示、Editor reload後のscript state、保存済みResourceの読み込みは実機操作で確認した方がよい。

### Finding-11: Source Registry detail表示は情報量が増えるほど縦に伸びる

各sourceにpathと `Item: cell数` を表示するようになったため、source内容は把握しやすくなった。一方で item数が多いOverlay sourceやpathが長いsourceでは、Dock上で縦方向に伸びやすい。

Source数を大量に扱う想定は薄いが、Loaded sourceの詳細を常時表示するか、折りたたみやtooltip中心にするかはUI方針として決める余地がある。

## Open Questions

### OpenQuestion-01: Adjacency rule parse APIの互換性

`parse_rules_text()` は今後も正規化済みDictionaryを返すpublic APIとして扱うか。互換性を重視するなら、legacy string keyを返す関数と、Editor向け正規化関数を分ける選択肢がある。

### OpenQuestion-02: Adjacency Rule Editorにfallback probabilityを渡すか

専用editorのvalidation statusはDockのWall Probabilityを知らない。Editor単体では `0.0` fallbackでよいか、Dockから開く場合は現在のfallback probabilityを渡してstatusを一致させるべきか。

### OpenQuestion-03: 空Deductor Floor Source queryの扱い

現在は警告して空floor集合をDeductorへ渡す。これを仕様として固定するか、空結果時はDeductorをskipするか、Placement Mask candidatesへfallbackするか。

### OpenQuestion-04: Deductor Floor Source universeの境界

Deductor Floor Source query resultはsource由来座標を広く使ってよいか。それとも現在Shape / cyclic domainへ制限した方が、Editorの他queryと一貫するか。

### OpenQuestion-05: `Clear Layer` はauto applyにも効くべきか

現状は全apply helperで共通に効く。手動 `Apply Layer` だけに効かせるより一貫しているが、Generate後の自動applyでも既存cellが残ることをユーザーは期待するか。

### OpenQuestion-06: Source Registry statusを分割するか

source件数 / 操作結果 / warningを単一labelで扱い続けるか。次のUI整理で、一覧statusと直近操作statusを分けるか。

### OpenQuestion-07: Item Poolのtile指定はcopy buttonで十分か

今回の `Floor Tile` / `Wall Tile` copy buttonを完了仕様として維持するか。次にTileSet atlas preview付きpicker、sample atlas拡充、またはsource / atlas候補dropdownへ進めるか。

### OpenQuestion-08: 六方向offset controlを独立Editor controlにするか

現在の3列button gridを使い続けるか。Mask / Reference / Deductor以外にも使うなら、hex形状表示、size連動、orientation対応を持つ再利用controlとして切り出す価値がある。

### OpenQuestion-09: Resource scriptの`@tool`化を正式仕様に含めるか

InspectorやEditor上のResource操作を安定させるため `@tool` を正式仕様とするか。正式化する場合、Resource Inspectorの実機確認と、`.tres` load / reloadのEditor上確認をテスト計画に含める。

### OpenQuestion-10: Source Registry detailの表示密度

pathとitem countを常時表示する現在の方式で進めるか。source数やitem数が増えるケースに備え、折りたたみ表示、tooltip、選択source詳細paneへ寄せるか。

## Follow-up Candidates

優先度が高い次の整理候補は以下である。

1. Adjacency Rule Set API互換性とEditor fallback表示の整理。
2. Deductor Floor Sourceの空結果 / universe境界の仕様確定。
3. Dock実機でのScrollContainer化、Query Row、Source Registry detail表示の視認性確認。
4. Source Registry statusの責務分離。
5. Item Pool tile pickerと六方向offset reusable controlの次期UI計画化。

