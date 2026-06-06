# GENERATIVE_REFERENCE_ITEMKEY 実装レビュー (2026-05-31)

## 対象

`docs/plan/GENERATIVE_REFERENCE_ITEMKEY_POLICY_2026-05-31.md` および `docs/plan/GENERATIVE_REFERENCE_ITEMKEY_IMPLEMENTATION_PLAN_2026-05-31.md` の要件に対する commit `179315d`。

## 総評

Core API の `generate_toric_adjacency_items_interruptible()` に `include_generated_reference: bool = false` が末尾引数として追加され、有効時に生成済み target item cell を動的 `reference_set` へ追加する。Editor Dock には `Generated Item Reference` checkbox が追加され、snapshot 経由で Core へ渡される。

変更は3ファイル（Core 12行、Dock 18行、test 172行）に収まり、計画の「既存呼び出し差分を小さくするため末尾引数追加」方針に忠実。全テストパス。

---

## 当初の要件より優れている実装

### 1. テストの確率ルール設計が巧妙
動的参照の効果を検証するため、`rules = {"default": 0.0, "1,1": 1.0}` を使用している。このルールでは「neighbor count=1 かつ component count=1」の candidate だけが配置される。先頭 candidate は静的 reference 1件の近傍にあるため配置され、その cell が reference_set に追加されることで2番目の candidate も近傍 count 1 を満たし配置される。Off の場合は2番目が配置されない。確率に依存せず決定論的に動的参照の効果を検証できる。

### 2. Core test で non-interruptible API の引数順を保持
`generate_toric_adjacency_items(..., seed, blocked, cyclic_size, neighbor_radius, include_generated_reference)` のようにセマンティックなパラメータ末尾に追加し、`interrupt_options` 引数が必要な interruptible 版だけダミー `{}` を渡す設計。計画の「代表案では既存呼び出し差分を小さくする」方針を満たしつつ、新規呼び出し元の可読性も保っている。

### 3. Cancel テストで動的参照 + 中断の組み合わせを検証
chunk_size=1 で即座に cancel し、先頭 candidate だけが配置された状態（`result["steps"] == 1`）と partial data の内容を固定している。cancel 時に reference_set が中途半端に更新されても data の consistency が崩れないことを確認。

---

## 要件に対する実装の不足

なし。全完了条件を満たす。

---

## UI 上の改善点

### 1. checkbox の位置
`Generated Item Reference` checkbox は `_build_overlay_adjacency_controls()` 内の Reference Query Row 直下、`Neighbor Radius` の上に配置されている。Adjacency Reference を使用するユーザーにとっては自然な位置だが、checkbox の tooltip `"Use generated target item cells as additional adjacency reference while this generation runs."` が長いため、Dock 幅が狭いと tooltip が切れる可能性がある。

### 2. Off 状態での checkbox 可視性
`Generated Item Reference` は常に表示されているが、`Enable Adjacency Reference` が Off のときは `_overlay_reference_container.visible = false` により非表示になる。この連動は正しいが、ユーザーが checkbox の存在に気づくのは Adjacency Reference を有効にした後になる。

---

## 機能・コード上の改善点

### 1. `include_generated_reference` が他の生成メソッドで未使用
`symmetric_toric_items` や `random_items` には動的参照の仕組みがない。これらは有意な candidate 順序を持たない（対称生成は領域一括、random は確率独立）ため、動的参照と相性が悪い。Plan の候補 C「Reference Source model を一般化する」が将来検討される場合、全生成方式に統一的な reference source インターフェースを導入する契機になる。

### 2. `generate_toric_adjacency_items` の引数が10個に
`cells, item_name, reference_cells, probability_rules, seed, blocked_cells, cyclic_size, neighbor_radius, include_generated_reference` の9必須 + interrupt_options。Plan でも言及されている dict 化（`options: Dictionary`）への移行を検討する時期かもしれない。

---

## テストに対する評価

| 計画のテスト | 実装 |
|-------------|------|
| Core: 生成済みitemが次candidateのneighbor countに反映 | ✅ `_test_toric_adjacency_items_can_reference_generated_item` |
| Core: toric wrap + generated reference | ✅ `_test_toric_adjacency_generated_reference_wraps` |
| Editor: checkbox On/Off → snapshot反映 | ✅ `_test_generation_dock_adjacency_generated_reference_snapshot` |
| Editor: On時だけ生成結果が変わる | ✅ `_test_generation_dock_adjacency_generated_reference_changes_result` |
| cancel時にpartial data非反映（既存保証） | ✅ `_test_toric_adjacency_generated_reference_preserves_cancel` |

TEST.md 更新も含め、全項目充足。
