# REPAIR-17 / REPAIR-18 redesign spec (corrected from user feedback)

日付: 2026-06-24
状態: corrected design record（実装前。前回の first-pass 実装は要望を取り違えていたため再設計する）

## 0. 検証済みの前提（preset 破壊の有無）

- `addons/hex_map_kit/core/hex_randomizer.gd` は REPAIR 作業のどのコミットでも未変更（`git log` で確認）。
- preset `{Ilands=11, Maze=20, Discrete=24}` の重み配列（`DISTRIBUTION_2X2X2_BASE_113/200/240`, 値域 0..8, prob=weight/8）は健在。
- custom distribution は core で `if state.has("custom_dist"): prob = custom_dist.prob(...) else preset` の**完全独立分岐**。custom は preset を破壊しない。
- 結論: 熟練探索で得られた preset の意味は失われていない。移植元ディレクトリの復元は不要。

## 1. 共通の状態管理欠陥（前回実装の根本問題）

- 前回は preset と custom が両方表示され、「どちらが生成に適用されるか」が UI 形式から判定できない。
- 修正方針: distribution / rule の「適用ソース」を**単一の明示状態**にする。
  - REPAIR-18: dropdown に `Ilands / Maze / Discrete / Custom` を並べ、選択そのものが適用ソース。`Custom` を選んだ時だけ custom が適用される（`distribution_mode = preset|custom` を state に持つ）。
  - これは旧 Generate tab の挙動（custom を設定すると dropdown が preset から custom にトグルされ、適用が一目で分かる）に合わせる。

## 2. REPAIR-18 redesign（Markov Mesh custom distribution window）

### ターゲット層

Markov Mesh の仕組みを知るユーザー: cell を外周→内周に走査し、各 cell で「生成済みの隣接 3 cell」を参照した確率で壁を生成する、という前提を理解している人。

### 表示する意味（前回欠落）

- 各設定項目は「生成 cell に隣接する参照 3 cell が wall か floor か」の組み合わせを表す。raw な state 0..7 の数字羅列ではなく、**3 近傍の wall/floor 配置を hex で可視化**する。
- 壁生成確率は**色の濃さ**で表す。確率が高いほど生成 cell が濃く（黒寄り）。注意: 確率値と pixel 値の関係は反転する（高確率=黒=低pixel）。形式的に扱うと取り違えるので明示。
- 参照可能 cell が 2 個 / 1 個の edge case の確率設定も用意する。
- 参照 0 個ケースは旧 window でも未収録（他生成方式と共用UIの値が流用されていた）。要再検討項目として残す（無音にしない）。

### scale / parity

- 値域は preset と同じ **0..8**（prob = weight/8）に揃える。これにより custom を preset（Ilands/Maze/Discrete）から **load して編集**でき、探索的に使える。
- `HexWallDistributionResource.prob()` は weight/8 を返す形へ（現状の 0..1 直値から変更）。
- preset は独立のまま破壊しない。

### acceptance（REPAIR-18 再定義）

- dropdown で `Ilands/Maze/Discrete/Custom` を選べ、選択が適用ソースとして一意。
- `Custom` 時のみ custom が生成に適用される（preset と二重適用しない）。
- custom editor は 3 近傍の wall/floor 配置を hex で可視化し、確率を色濃度で表示。
- 各 state が「何を意味するか」を UI 上で説明できる（ラベル/凡例）。
- preset 不変の回帰 test + custom 適用 test。

## 3. REPAIR-17 redesign（Adjacency Rules window）

前回は (count, components) の行編集にしてしまったが、要望は**hex パネルによるパターン定義**である。

### 正しいデータモデル / UX

- hex パネルは**任意個数 add 可能**。各パネルが 1 つの近傍状態マッチングパターンを意味する。
- 各パネルは**生成 cell を中心**とし、周囲 6 cell（または選択した近傍形状）を hex 形状で表示。
- 中心以外の hex ボタンはクリックごとに**トグル**し、その近傍位置の「参照対象の有無」を切り替える。
- 色規約は旧 Markov window に合わせる: **参照対象あり=黒 / なし=白**。
- パターンごとに生成確率を数値設定でき、視覚的には**色の濃さ**で表す（確率と色濃度の値関係は反転に注意）。

### パターンの保存キー（重要・core 拡張）

- マッチングパターンは「近傍形状範囲内の、各**連結成分**（ひと塊りに連結）の cell 数を、**並び順不同・重複可**の列（multiset）」として復元可能な形で保存する。
- 例: トグル結果から連結成分サイズの multiset `{2,1}` / `{3}` / `{1,1,1}` / `{2,2}` を算出してキーにする。
- 現 core は `Vector2i(count, components)` でしか分類していない（`{2,2}` と `{3,1}` を区別できない）。要望を満たすには core を **component-size multiset キー**へ拡張する。
  - `_adjacency_reference_stats` に `component_sizes`(sorted list) を追加。
  - `_adjacency_rule_probability` を multiset キー一致 → (count,components) → default の順で評価。

### acceptance（REPAIR-17 再定義）

- hex パネルを複数 add/remove でき、中心以外のトグルで参照有無パターンを編集できる。
- 参照あり=黒/なし=白、確率=色濃度で表示。
- パターンは連結成分サイズ multiset として保存・復元できる。
- core が multiset キーで確率を引く（`{2,2}` と `{3,1}` を区別）。
- text 入力は primary から廃止（既存 graph 互換のためのfallbackのみ可）。
- multiset 分類 + 生成反映の test。

## 4. 前回 first-pass の扱い

- REPAIR-18: custom_distribution の core 配線と Resource 雛形は流用可。ただし UI（raw 8 spin）と scale(0..1)・状態管理(preset/custom 不明)は作り直す。
- REPAIR-17: structured(count/components) editor は破棄し、hex パネル + multiset モデルへ作り直す。core 拡張が必要。
- よって REPAIR-17 / REPAIR-18 は `COMPLETE` を取り下げ、再設計タスクとして再オープンする。

## 5. 未確定（ユーザー判断）

1. REPAIR-18 の custom 値域を 0..8（preset と統一・load 可）にしてよいか（推奨）。
2. REPAIR-17 の core を multiset キーへ拡張してよいか（生成 semantics が変わる）。
3. 参照 0 個ケース（Markov）の扱いをこの機に定義するか。
4. これら window は editor 上の視覚が完了根拠（first impression）。headless では pixel 確認不可のため、実装後にユーザーの editor 確認が必要。
