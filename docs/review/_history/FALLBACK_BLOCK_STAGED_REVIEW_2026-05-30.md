# FALLBACK_BLOCK staged review 2026-05-30

対象:

- 要件概要: `docs/review/FALLBACK_CLASSIFICATION.md`
- 実装計画: `docs/review/FALLBACK_BLOCK_IMPLEMENTATION_PLAN.md`
- staged changes: `addons/hex_map_kit/` and `tests/`

確認:

- `./tools/test.sh` は成功した。
- macOS の `get_system_ca_certificates` ERROR は `docs/TEST.md` 記載の既知非致命ログとして扱った。

## 当初要件より良い点

- Legacy Mask / Reference controls の削除は、UIと評価経路の両方から実施されている。`Primary/Overlay check + text` と `Any Item/All Items` の古い入口が残らないため、fallback分類で問題になっていた暗黙selectorの入口は大きく減っている。
- Query Row評価が `_overlay_shape_universe()` に集約され、Mask / Reference / Deductor Floor が同じ Shape universe 基準へ寄せられている。これは `FALLBACK_CLASSIFICATION.md` の Crop On/Off によらず現在 Shape / Size を universe にする方針に沿っている。
- toric source の評価は、sourceの `cyclic_size` でwrapした代表をShape universe側へ逆引きする実装になっている。単なるoffset後の1代表だけでなく、universe内の同一toric代表を拾える方向に進んでいる。
- Adjacency Rules の Wall Probability fallback は Dock 側と `HexAdjacencyRuleSet` 側の呼び出しから外れている。少なくとも slider 値が invalid rules の暗黙 probability として混入する経路は消えている。
- Overlay default item name が `"OverlayItem"` から `"Item1"` に変更され、ユーザー要望と一致している。

## Findings

### Finding-01: empty Placement Mask でも Generate が止まらない

Severity: High

`FALLBACK_CLASSIFICATION.md` は、Query Row が1行以上あり、その結果が空なら「候補cell:0」とし、Generate は実行されないことを求めている。現在の実装は `_overlay_mask_cells_for_snapshot()` で warning を出して空配列を返すだけで、`_generate_map()` はその snapshot のまま generation thread を開始する。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2503`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2578`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2780`

影響:

- ユーザーには warning だけ出るが、Generateボタン実行自体は成功扱いになりうる。
- 要件の「入力段階で拒否」「Generateは実行されない」が未達。
- テストは warning と空候補の経路を通しているが、Generate拒否やボタン無効化を固定していない。

改善案:

- snapshot作成時に `overlay_mask_empty_blocked` のような状態を返すか、`_generate_map()` 開始前に Mask rowsありかつ candidate空を判定して false return する。
- UIとしては Generate button disabled か、押下時に status 表示して generation thread を開始しない方が要件に近い。

### Finding-02: Deductor Floor未指定時の complement 方針が snapshot / UI / test に反映されていない

Severity: High

要件では、Deductor Floor Source 未指定時は Placement Mask candidates ではなく「生成された配置cell集合の complement」を floor 集合にする。staged実装は `_generate_overlay_data_from_snapshot()` の後段で complement に置き換えるが、snapshot作成時とUI statusは旧仕様のまま `Placement Mask candidates` を返している。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2787`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2790`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2996`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2998`
- `tests/test_editor_plugin.gd:1218`

影響:

- snapshot上の `overlay_deductor_floor_cells` が実際にDeductorへ渡される値を表さない。
- UI status は `Default: Placement Mask candidates` と表示し、ユーザー要望と逆の説明になる。
- テストも「未指定時はPlacement Mask candidates」を期待しており、今回の要件に対する回帰検知になっていない。

改善案:

- snapshotに「Deductor Floor Sourceが明示指定されたか」を持たせ、generation側は snapshot の情報だけで分岐する。
- 未指定時の status を complement 方針に合わせる。
- テストは未指定時に実生成結果へ complement が使われることを確認する。

### Finding-03: generation thread 内で live UI state を参照している

Severity: High

`_generate_overlay_data_from_snapshot()` は generation thread から呼ばれるが、Deductor complement 分岐で `_query_rows_enabled()` と `_overlay_shape_universe()` を呼んでいる。どちらも Dock の live UI controls / row state を読むため、snapshotベース生成の境界を破っている。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2521`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2587`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2997`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2998`

影響:

- 通常の `_generate_map()` 経由では、worker thread から Godot UI node を読む形になる。
- controlsがdisabledでも、snapshotに閉じていないため、将来の非同期操作やテストで実行時設定とsnapshotがずれる。

改善案:

- `_overlay_shape_universe()` 相当の計算を snapshot dictionary から行う純粋関数に分離する。
- Deductor Floor Sourceの有無も snapshot に保存し、generation threadでは UI row を読まない。

### Finding-04: toric source繰り返し展開が Crop result item cells に反映されない

Severity: Medium

Query Row評価本体は `_query_row_contain_cells_in_universe()` を使うようになったが、Crop resultを作る `_overlay_crop_result_data()` は item別cellsを作る際に旧 `_query_row_contain_cells()` を使っている。この関数はtoric sourceを1代表へwrapするだけで、Shape universe内の繰り返し代表を展開しない。

該当箇所:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2723`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2921`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2929`

影響:

- Overlay Generate の candidate cells と、Crop resultとして保存・表示される item cells が一致しない可能性がある。
- Count label は Crop result のitem cellsを数えるため、toric sourceでは表示数も過小になりうる。

改善案:

- Crop result item cells でも `_query_row_contain_cells_in_universe(row, universe)` を使う。
- Plan 5e の toric repeated representatives ケースを Crop resultにも追加する。

#### ユーザー判断

幾何学的な問題に対する指針としては端的すぎて、この指摘からは再現可能なテスト仕様を想像できない。

### Finding-05: Adjacency Rule Editor が invalid entry を fallback default と表示する

Severity: Medium

`HexAdjacencyRuleSet` から `used_fallback` は削除されたが、`HexAdjacencyRuleEditor` の status text は invalid entry があるだけで `" (fallback default)"` を表示する条件に変わっている。これは fallback削除の方針と逆のUI表示になる。

該当箇所:

- `addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd:95`
- `addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd:99`

影響:

- Adjacency Rule Editor上で、fallbackが残っているように見える。
- valid ruleとinvalid entryが混在する場合にも `"fallback default"` が表示される。

改善案:

- `"fallback default"` 表示を削除し、invalid entryの表示だけにする。
- Dock側とEditor側で同じ status文言になるようテストを追加する。

## UI上の改善点

- empty Placement Mask時のUI feedbackは warning log だけでは不足している。Dock上のstatus labelとGenerate button disabledが必要。
- Deductor Floor Source未指定時のstatus文言は旧仕様のままなので、complement方針をユーザーが理解できる文言に更新する。
- Adjacency Rule Editorの `"fallback default"` は削除する。fallback削除が今回の主目的なので、残るとUI上の混乱が大きい。

## 機能・コード上の改善点

- `_generate_overlay_data_from_snapshot()` は snapshot以外を読まない形に整理する。特にthread内でUI controlを参照しない。
- `_evaluate_query_rows(query_kind, crop_enabled := false)` の `crop_enabled` は実質未使用になっている。呼び出し側も含めて削除すると、Crop On/Offでuniverseが変わる旧仕様の名残を減らせる。
- `_query_row_contain_cells()` はCrop result以外で不要になっている。Crop result側もuniverse-aware関数へ寄せた後に削除を検討できる。

## テスト不足

- Query Row 0行の Mask が Shape/Size universe 全体になるテスト。
- Query Row 1行以上で Mask result が空のとき、Generateが実行されないテスト。
- `_current_data == null` でもOverlay GenerateがQuery Row / Shape universeだけで動作するテスト。
- Deductor Floor Source未指定時に、生成済み配置cell集合の complement がDeductor floorに使われるテスト。
- toric sourceの繰り返し代表がuniverse内に複数あるケースのテスト。実装計画の Case A / B / C はまだ十分に固定されていない。
- Crop resultでtoric sourceの繰り返し代表が保存・countされるテスト。
- Adjacency Rule Editorで invalid entry が `"fallback default"` と表示されないテスト。

## 不明点

- `HexAdjacencyRuleSet.parse_rules_text_report()` は全entry invalid時に `{"default": 0.0}` を返している。実装計画にはこの形が書かれているが、要件本文の「defaultではない」を厳密に読むなら、空rules `{}` を返し、generator側の既存 `0.0` fallbackに任せる方が自然かもしれない。どちらを仕様にするか確認したい。
- `docs/manual/MANUAL_EDITOR_PLUGIN.md` と `docs/complete_on_test/EDITOR_OVERLAY_REMAINS_2026-05-30_DEDUCTOR_FLOOR_SOURCE.md` には旧fallback説明が残っている。今回の修正完了時に更新対象にするか、別レビュー後にユーザー承認を待つか確認が必要。


### ユーザー判断

空rules `{}` を返すのがよい。その上でgenerateは実行しない。既存 `0.0` fallbackはアルゴリズム上の不都合でなければ削除する。

## 対応記録

2026-05-30 追記:

- Finding-01: Mask Query Row が1行以上あり、評価結果が空の場合はGenerate buttonをdisabledにし、`_generate_map()` 直呼びでも実行前に停止する。Query Row 0行はShape universe全通過として維持する。
- Finding-02 / Finding-03: Deductor Floor Source未指定時は、snapshotにShape universeとsource有無を保持し、generation threadではUI stateを読まずに生成後配置item集合のcomplementをDeductor floorとして使う。
- Finding-04: 再現条件を `cyclic_size=3` のtoric source、item `(2,0,0)`、offset `+Q`、Shape universe `Rect 5x1` として具体化した。この場合、wrapped代表が一致する `(0,0,0)` と `(3,0,0)` の両方をQuery result / Crop resultに含める。
- Finding-05: `fallback default` status表示を削除し、invalid entryのみを表示する。
- 不明点: `HexAdjacencyRuleSet.parse_rules_text_report()` は全entry invalid時に `rules={}` を返す。DockのAdjacency Overlayは `rules={}` の場合Generateを実行しない。

確認テスト:

- `tests/test_hex_adapter.gd`
  - Adjacency Rule Setの全invalid入力が `rules={}` になること。
- `tests/test_editor_plugin.gd`
  - empty Placement MaskでGenerateしないこと。
  - empty Adjacency RulesでGenerateしないこと。
  - Deductor Floor Source未指定時にgenerated complementを使うこと。
  - toric source代表展開がQuery result / Crop resultに反映されること。
  - Adjacency Rule Editor / Dock statusに `fallback default` が出ないこと。

検証:

- `./tools/test.sh` 全テスト通過。
