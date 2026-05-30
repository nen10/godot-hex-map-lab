# BRAINSTORM_OPEN_TOPICS_2026-05-30.md

この文章はagentによる状況整理です。

## 目的

README、`docs/plan/`、既存レビュー文書から、今後の実装機能・改善候補をブレスト段階で集約する。

ここに挙げる項目は承認済みの実装計画ではなく、次に `docs/plan/` へ分割する前の論点メモとして扱う。plan化する場合は、入力・出力・resource schema・テスト概要を明確にする。

## 全体観

- Editor Dock は Primary / Overlay generation、Source Registry、Query Row、Crop、Apply Write、Generate History まで接続済み。今後は「生成できる」から「設定意図が読み取れる」「結果の状態が確認できる」方向の改善余地が大きい。
- Core / Adapter は Hex shape、toric、overlay resource、TileMapLayer apply の基盤が揃っている。残る改善は重複削減、snapshot境界の明確化、toric query 評価の効率化が中心。
- Runtime / Gameplay Layer は `HexTileMapLayer` Phase 2 以降と、マップの手動編集機能が大きな実装候補。
- Documentation / sample は公開利用に向けた整備候補。manual化候補はユーザー要望または完了承認された機能を対象にする。
- fallback は仕様根拠にしない。一時対応として残っている表現や挙動は、plan化時に期待動作へ置き換える。

---

## A. Editor Dock UX / 表示改善

### A-1. Apply Policy / Write Mode の表示整理

既存の `"Apply Write"` は TileMapLayer clear と current data 更新方式の両方を表すため、UI上の意味が読み取りにくい。ラベルを `"Write Mode"` などへ変更するか、tooltipで「Target layerへの書き込み」と「current overlay更新」を説明する余地がある。

ユーザー追記:

- apply policy はラベル名変更を検討する。
- Primary mode では Existing Item policy を Merge 相当で固定し、disabled 表示にする案がある。

テスト候補:

- Primary mode で Existing Item policy が固定・disabled になる。
- Overlay mode で Existing Item policy が有効になり、Merge / Replace / Skip が current overlay 更新に反映される。
- `Clear And Write` / `Add Item` の matrix が Primary / Overlay / Crop result apply で崩れない。

### A-2. Deductor Floor Source status の文言改善

未指定時の status `"Default: generated complement"` は実装者向けに見える。ユーザー向けには `"Default: all cells without generated items"` のように、生成済み item を除いた floor 候補であることを説明する表現がよい。

ユーザー追記では「これは対応しても良い」とされている。

テスト候補:

- Deductor Floor Source 未指定時の status が complement 方針を示す。
- 明示指定時は source / item / cell count が表示される。

### A-3. Source Registry と Overlay source stack の状態表示

Source Registry は `display_name [resource_type]` だけでは、query source として使う判断材料が少ない。itemごとのcell数、resource path、reload結果、Overlay source stackの合成対象数を見えるようにする余地がある。

テスト候補:

- `HexMapResource` で `Any` / `Floor` / `Wall` のcell数を表示する。
- `HexOverlayResource` で user item key ごとのcell数を表示する。
- Crop Off / Overlay で合成対象が0件の場合、Dock上のstatusで理由が分かる。

### A-4. Query Row offset control の再利用部品化

Query Row の `+Q` / `-R` / `+S` / `-Q` / `+R` / `-S` は横長になりやすい。`hex_dist_editor.gd` の表示を参考に、六方向操作をグラフィカルなcontrolとして切り出す案がある。

テスト候補:

- 6方向ボタンで `HexVector` offset が更新される。
- Dock幅が狭くても主要controlが読める。
- 同じcontrolを Mask / Reference / Deductor Floor Source で使い回せる。

### A-5. Crop の反復編集UX

Crop On 中に Shape / Size / Mask Query Row を編集すると Crop Off に戻る。現在の仕様として成立しているが、Crop結果を見ながらパラメータを微調整したい場合は、編集後に再計算してCrop状態を維持するモードも考えられる。

テスト候補:

- Crop保持モードでは Mask Query Row 編集後に結果が再評価される。
- 通常モードでは従来通り Crop Off に戻る。

ユーザー追記:

使用感が報告されていない状況で検討が先走っている。

### A-6. Generate History の配置と表示名

Generate History は seed 周辺ではなく Save / Generate に近い概念として表示した方が意図が明確になる可能性がある。ファイル名は `overlay-combination` のように、アルゴリズム内部名ではなくユーザー向け語彙を使う方針を維持する。

テスト候補:

- `Generate Combination` On の履歴名に `overlay-combination` が含まれる。
- cancel / 失敗時に履歴sourceが追加されない。

ユーザー追記:

レイアウト調整予定

---

## B. Overlay / Query 生成機能

### B-1. Generative Reference ItemKey

Reference Query Row に `Generative Reference ItemKey` checkbox を追加する案。Adjacency Reference でも、生成した item 自身を動的に参照cellへ加えていく方式にする。Primary Markov Mesh, non-Adj Markov Mesh と同様に、生成が進むにつれて reference cells が増え、重複cellは1つのcellとして扱う。

入力候補:

- Reference Query Rows
- `Generative Reference ItemKey` checkbox
- 生成対象 item key
- 生成順序 / scan order

出力候補:

- 静的 reference cells と生成済み item cells の union
- Adjacency probability 計算に使う動的 reference set

テスト候補:

- 生成済み item が次cell以降の adjacency reference に含まれる。
- 静的 source と生成済み item が同じcellを指す場合は重複しない。
- checkbox Off では従来の静的 Reference Query Row のみを使う。

### B-2. Reference Query Row 空結果時の警告

Mask Query Row は空結果でGenerateを止める方向に整理済み。Reference Query Row が1行以上あり、結果が空の場合は、ユーザーの意図と異なる生成になる可能性があるため、warning 表示またはGenerate blockを検討する。

テスト候補:

- Reference Query Row が空結果の場合、Dock statusに警告が出る。
- Adjacency Reference が必須のモードではGenerate可否が明確に制御される。

ユーザー追記:

不要です。

### B-3. toric source 代表展開の共有化

`_query_row_contain_cells_in_universe()` は universe から toric 代表への逆引きマップをrowごとに作る。同一 `cyclic_size` の row が複数ある場合、逆引きマップを共有すれば評価コストを下げられる。

テスト候補:

- 同じ `cyclic_size` の複数rowで評価結果が変わらない。
- toric source の繰り返し代表が Query result / Crop result / count に一貫して反映される。

ユーザー追記:

優先度低い

### B-4. Adjacency Rules parse 結果のキャッシュ

`_current_generation_block_reason()`、`_overlay_adjacency_rules()`、`_refresh_adjacency_rules_status()` がそれぞれ `parse_rules_text_report()` を呼ぶ。`_refresh_controls()` などで1回評価してキャッシュできる。

テスト候補:

- valid / invalid rules のstatus表示が変わらない。
- 全invalid時に `rules={}` となり、Adjacency Overlay Generate が実行されない。

ユーザー追記:

優先度低い

---

## C. Core / Adapter 整理

### C-1. Shape universe 計算の統一

`_overlay_shape_universe()` は UI control を直接読み、`_shape_universe_from_values()` はsnapshot値から読む。前者を後者の呼び出しに寄せると、generation thread からlive UI stateを読む経路を減らせる。

検討メモ:

```gdscript
func _overlay_shape_universe() -> Array:
    return _shape_universe_from_values(
        _uses_symmetric_generation(),
        _shape_option_symmetric.selected if _uses_symmetric_generation() else _shape_option_simple.selected,
        int(_hex_radius_spin.value),
        int(_rect_width_spin.value),
        int(_rect_height_spin.value),
        int(_gen_radius_spin.value)
    )
```

テスト候補:

- Simple / symmetric Hexagon で同じradiusのuniverseが一致する。
- `SHAPE_TORUS` は generation radius 由来の square universeを使う。
- snapshotから計算したuniverseとUIから計算したuniverseが一致する。

ユーザー追記:

優先度低い

### C-2. Hexagon canonicalization 周辺の重複削減

`test_hex_map_generation.gd` の `_canonical_hexagon_cells()` は `HexMapData.hexagon(radius).cells` と同じロジックになっている。期待値として実装APIを参照するか、別fixtureとして明示するか整理余地がある。

テスト候補:

- `HexMapData.hexagon(0)` が center cell のみを返す。
- radius 1 / 2 / 3 のhexagon cell集合が canonical universe と一致する。

ユーザー追記:

優先度低い

### C-3. 未使用引数と内部名の整理

`_overlay_deductor_floor_cells_for_snapshot(default_floor_cells)` の `default_floor_cells` は不要になっている可能性がある。内部名も fallback 由来の表現が残る場合は、仕様化された名前へ置き換える。

テスト候補:

- 引数削除後も snapshot に必要な Deductor Floor Source 状態が残る。
- generation側がsnapshot以外のUI stateを読まない。

ユーザー追記:

優先度低い

---

## D. Runtime / Gameplay Layer

### D-1. `HexTileMapLayer` Phase 2 / Phase 3

`docs/plan/TILEMAP_LAYER.md` にあるクリック操作、連結性クエリ、一括編集、ホバー表示、経路アニメーション、複数TileMapLayer管理を進める候補。

テスト候補:

- `local_to_hex()` 経由でクリック位置が `HexVector` へ変換される。
- `cell_clicked(hex)` signal が発火する。
- `connected_component(hex)` と `is_map_connected()` がcore結果と一致する。
- `fill_region()` / `randomize_walls()` がresourceと表示を更新する。

### D-2. toric / infinite map のループ表示

Toric map では同一cellの複数代表が表示上に出るため、視覚的に短い経路表示やカーソル追従のloop表示が必要になる可能性がある。Infinite map では代表同一化をせず、non-toricな近傍処理で扱う。

テスト候補:

- toric mapで視覚的に短い代表を選んでpathを表示する。
- toric wrapをまたぐpathが表示上で不連続に見えない。
- infinite mapでは異なる座標を同一cellとして扱わない。

### D-3. マップのマニュアル編集機能

`docs/plan/PENDING.md` の大きな候補。生成Dockとは別のeditor toolとして、shape / wall-floor / tile paint / object / label を座標単位で編集する。

入力候補:

- selected `HexMapResource`
- selected editable layer
- edit mode
- paint target `HexVector`
- tile / object / label payload

出力候補:

- updated `HexMapResource`
- updated `TileMapLayer`
- undoable editor command
- label / object database resource

テスト候補:

- wall / floor edit が resource roundtrip 後も維持される。
- tile paint payload が coordinate ごとに保存される。
- label / object payload が coordinate ごとに保存される。
- undo / redo command が resource と TileMapLayer の両方を戻す。

---

## E. Documentation / 配布

### E-1. `docs/TEST.md` の概要更新

`test_editor_plugin.gd` の概要に、Apply Write統合、Hexagon canonization、block status prefix、empty Mask / empty Adjacency Rules block、Deductor complement、toric representative expansion などを追記する余地がある。

### E-2. Manual / Screenshot / 図

Dock は Source Registry、Query Rows、Crop、Deductor Floor Source、Adjacency Rules、Apply Write、Existing Item、Generate History まで増えている。ユーザーがmanual作成を要望するか、完了承認した機能については、スクリーンショットまたはセクション図を作ると全体像が把握しやすい。

### E-3. 公開用整備

`docs/plan/REMAINS_NON_EDITOR_PLUGIN.md` にある API reference、sample project / sample scene、配布package構成は公開利用に向けた候補。

テスト候補:

- sample scene が headless debug test でロードできる。
- addon package に必要ファイルが含まれる。
- public API example が Godot script test として実行できる。

---

## 小さく着手しやすい候補

- Deductor Floor Source status をユーザー向け文言にする。
- Apply Write / Existing Item のラベルとdisabled表示を整理する。
- `docs/TEST.md` の `test_editor_plugin.gd` 概要を現在のテスト内容に合わせる。
- `_overlay_shape_universe()` を `_shape_universe_from_values()` 経由に寄せる。
- Adjacency Rules parse result をcacheする。
- `_overlay_deductor_floor_cells_for_snapshot` の未使用引数を削除する。

## 大きめの候補

- Generative Reference ItemKey。
- Query Row offset graphical control。
- Crop保持再計算モード。
- Runtime click / loop path / connected component helper。
- マップのマニュアル編集tool。
- 公開用 sample project / API reference / package整備。

上記の方針・詳細実装計画は `docs/plan/BRAINSTORM_OPEN_TOPICS_PLAN_INDEX_2026-05-31.md` に分割した。
