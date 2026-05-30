# GENERATIVE_REFERENCE_ITEMKEY_POLICY_2026-05-31.md

## 目的

Adjacency Reference を使うOverlay生成で、静的なReference Query Rowだけでなく、その生成中に配置されたtarget item自身を以後の参照cellへ加える。

これにより、Primary Markov Meshやnon-Adj Markov Meshが持つ「先に生成した壁・itemを次の確率計算へ反映する」性質を、Adjacency Reference modeにも導入する。

## 現状

- Editor Dock は `overlay_reference_cells` をsnapshotへ保存し、generation threadではその静的配列だけを `generate_toric_adjacency_items_interruptible()` へ渡す。
- Core API の `generate_toric_adjacency_items_interruptible()` は `reference_cells` から `reference_set` を作り、各candidateのneighbor count / component countを計算する。
- 生成したitem cellは `HexOverlayData` に追加されるが、同じgeneration内の `reference_set` へは追加されない。

## 方針

代表案として、Core APIへ `generated_reference_item_key` 相当の動的参照オプションを追加する。

このオプションが有効な場合、candidate cellにtarget itemを配置した直後、そのcellを `reference_set` に追加する。以後のcandidateは、静的Reference Query Rowの結果と生成済みtarget itemのunionを参照する。

重複cellは `HexMapData.make_set()` のkey単位で1つとして扱う。toric mapでは `cyclic_size` によってwrapした代表keyを使う。

## 比較事項

### 候補A: Core APIのbooleanとして導入

- `generate_toric_adjacency_items_interruptible()` に `include_generated_reference` を追加する。
- Editor Dock はcheckbox状態をsnapshotに保存し、Core APIへ渡す。
- headless testで生成順序とreference_set更新を直接検証できる。

採用候補。既存の静的reference APIに最小限の拡張で目的を満たせる。

### 候補B: Editor Dock側で逐次生成を肩代わりする

- Editor Dockがcandidateを走査し、各cellでCore helperを呼ぶ。
- UI固有のsnapshot構造がCore生成ロジックへ侵入しにくい一方、progress / cancel / seed処理がDock側へ分散する。

代表案にはしない。

### 候補C: Reference Source modelを一般化する

- 静的source、query source、generated item sourceを同じReference Sourceとして扱う。
- 今後の参照source拡張には向くが、最初の導入としてはschema変更が大きい。

将来の再設計候補として残す。

## 破壊的変更候補

- `generate_toric_adjacency_items_interruptible()` の引数順を整理し、optional dictionaryへ移す。
- snapshot keyを `overlay_reference_cells` だけでなく `overlay_static_reference_cells` / `overlay_generated_reference_enabled` に分ける。
- Editor Dockの `"Adjacency Items"` 表示を `"Reference Items"` に変更し、静的参照と生成済み参照の違いをUI上で明確にする。

破壊的変更を行う場合も、既存テストで固定されている静的Reference Query Rowの動作は、新しいOff状態のテストとして維持する。

## Fallback扱い

静的Reference Query Rowのみで生成を続ける現状は、この課題に対するfallbackとして扱う。仕様として固定せず、checkbox Off時の互換挙動としてのみ残す。

`reference_cells` が空のときに別の確率へ置き換える動作は導入しない。生成済み参照が有効なら、scan order上で最初に配置されたitemから参照が増える。配置されなければreferenceは空のまま進む。

## 入出力

入力:

- Reference Query Rowsの評価結果
- `Generative Reference ItemKey` checkbox
- target item key
- candidate cells
- adjacency probability rules
- seed
- cyclic_size
- neighbor_radius

出力:

- `HexOverlayData`
- 生成中に更新されるreference_set
- progress / cancel status

## テスト方針

- Core testで、先に生成されたtarget itemが次candidateのneighbor countに反映されることを固定する。
- Editor Dock testで、checkbox On / Off がsnapshotに反映されることを検証する。
- toric testで、生成済みitem cellをwrapしたrepresentative keyで重複排除することを検証する。
- cancel時にpartial dataがcurrent overlayへ反映されない既存保証を維持する。

## 完了条件

- Core APIとEditor Dockが同じ方針で動的referenceを扱う。
- checkbox Offで既存の静的Reference Query Row生成と同じ結果になる。
- checkbox Onで生成済みtarget itemが以後のreferenceに加わる。
- `docs/TEST.md` の該当テスト概要が更新される。
