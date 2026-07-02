# Criteria Resource Model — 資産管理と依存連動の統一設計（draft round 1）

日付: 2026-07-03
状態: **design draft**（`DESIGN_DIALOGUE.md` round 2 確定を受けた別紙。本ドキュメントをやりとりで確定後、ROADMAP / queue 化する）
関連:
- `DESIGN_DIALOGUE.md`（R2-1 軸 / R2-2 採用リスト / R2-6 回答）
- `docs/design/GENERATION_GRAPH_MODEL.md` §7/§10（embed vs reference・load モード）
- `docs/design/PRODUCT_DEFINITION.md` §9（samples と production asset を混ぜない）

---

## 0. 確定済み前提（round 2 回答）

1. 資産化の対象は 5 種: **adjacency rules / markov distribution / item pool / graph / 生成結果**。
2. 生成結果 resource は **(b) 出力 data 込み**（切替の即時性を優先。大マップの再生成コスト回避）。
3. Batch N / Seed randomize / Shape randomize は UI から撤去（headless の複数 run 能力は残す）。
4. **依存連動の要求（Q-R2-1 回答・本設計の中核）**: 設定項目および asset ごとの「生成方式決定のためのノードグラフ内での核依存関係」が **UX 動線として UI に分かりやすく反映**され、一つの項目を設定したときに他の項目が連動して変わる**状態遷移モデルによる管理機能**を旧 Generate タブから引き継ぐ。現状はこれが不足し、**ユーザーに暗黙知を要求する設定変更作業を過剰に強いている**。schema 中央化（REPAIR-21）と並んで明確化する。
5. default 常時有効原則（R2-3）: 全 param は default で充足され、default のまま Generate しても常に有効な生成が走る。gate UI は作らない。

## 1. 置き場所規約 — bundled preset と project asset の二層

**現状の欠陥（コード裏取り）**: `HexAdjacencyRulePresets.save()` は addon 内 `res://addons/hex_map_kit/assets/adjacency_rule_presets/` に書き込む。ユーザー資産が addon tree に混入し、(1) addon 更新で消える、(2) sample/production 分離（PRODUCT_DEFINITION §9）に違反する。

規約案:

| 層 | 置き場所 | 書込 | 役割 |
|---|---|---|---|
| **bundled preset** | `res://addons/hex_map_kit/assets/<kind>_presets/` | **read-only**（Save 先に選ばせない） | 学習素材・出発点。addon と一緒に配布 |
| **project asset** | `res://hex_map/<kind>/`（default。project setting で変更可） | 可 | ユーザーの「編集した指標」の実体。addon 更新に生存 |

- `<kind>` = `adjacency_rules` / `wall_distributions` / `item_pools` / `graphs` / `results`。
- 命名: file は snake_case、表示名は resource の `display_name`（現行 `HexAdjacencyRuleSet` と同じ）。
- UI: Preset dropdown は **bundled + project を統合表示**し、出所を区別（bundled は上書き不可。「Duplicate to project」で複製してから編集）。

## 2. 資産種別ごとの形

| kind | resource class | 中身 | 現状 → 変更 |
|---|---|---|---|
| adjacency rules | `HexAdjacencyRuleSet`（既存） | patterns(multiset) + default 確率 + display_name | **基準形**。置き場所のみ二層化（§1） |
| markov distribution | `HexWallDistributionResource`（既存・UI 未接続） | `weights_by_count`（参照 cell 数別 0..8 weight）+ display_name 追加 | graph params への dict 埋込をやめ resource 化。**組込み preset（Ilands/Maze/Discrete）を「root として読込」**= preset の重み配列から resource を生成し custom 編集の初期値にできる（REPAIR-18 の 0..8 スケール統一を利用） |
| item pool | `HexItemPoolResource`（**新設**） | entries: `[{name, weight, limit}]` + display_name | REPAIR-19 の方式依存フィールド（weighted=weight / limited=limit）を両方保持する 1 資産。inspector の行 editor はこの資産の editor になる |
| graph | `HexGenerationGraphResource`（既存） | nodes/edges/promote_targets/semantics | **template = bundled graph preset** として同じ規約に乗せる（rooms / maze / …）。Simple profile は template の一種に統合（R2-4） |
| 生成結果 | `HexGenerationResultResource`（既存） | **使用 field を限定**: `result_id` / `seed` / `primary_map` / `overlay_maps` / `generation_snapshot`（graph snapshot 含む）/ `metadata` | (b) data 込み保存。`score` / `validation_*` / `overlay_mode` 等の park 系 legacy field は本機能では**書かない**（存続はするが使わない） |

## 3. embed vs reference（graph param と資産の関係）

| モード | 意味 | 用途 |
|---|---|---|
| **inline** | node params 内で完結（資産化しない） | 使い捨ての調整。現状の既定。**「Save as asset」で reference へ昇格可能** |
| **reference**（path） | graph param が project asset を参照 | **既定の推奨**。同じ rule set / distribution / pool を複数 node・複数 graph で共有し、**資産側の編集が全参照点へ波及**（編集した指標＝単一 source of truth） |
| **embed**（snapshot） | 保存時に値を graph へ固める | 出荷・runtime 自己完結（GENERATION_GRAPH_MODEL §7/§10 の load モードと同じ語彙）。graph resource 保存時の「embed に固める」操作で変換 |

**表示規則**: inspector / node title は、その criteria が `inline / 参照中: <名前> / embed 固定` のどれかを**常に明示**する。暗黙の埋込・暗黙の参照を作らない。

## 4. 共通操作文法 — criteria editor の統一 UX

adjacency rules window（磨き込み中）を**基準形**として全 kind に同じ文法を適用:

1. **Preset dropdown**: bundled + project 統合、**選択そのものが適用ソース**（REPAIR-18 の「dropdown 選択＝適用ソースの単一明示状態」の一般化）。
2. **Load**（選択資産を root として読込 → custom 編集開始）/ **Save** / **Save as**（project へ）/ **Duplicate to project**。
3. visual editor 本体は kind ごとの専用 UI（hex panel / 参照 cell 別 weight 盤 / pool 行）。
4. **即時反映**: 編集値は window を閉じ直さずに summary・node title・関連 param へ反映される。「各パラメータが不快感なく UI に反映される」を DoD とし、実描画キャプチャで判定（V8）。

## 5. 依存連動モデル — 状態遷移の継承（本設計の中核）

旧 Generate タブの `hex_map_gen_state_evaluator.gd` は「一つの設定変更が他の可視性・ラベル・排他を連動更新する」状態遷移を一手に持っていた（例: symmetric ⇔ radius/markov/toric、overlay ⇔ adjacency XOR limit、確率ラベルの意味変化）。graph 化でこの連動が失われ、**どの設定がどの生成方式に効くかが暗黙知になっている**。これを schema の宣言として復元・昇格する:

### 5.1 schema 項目の宣言（REPAIR-21 の acceptance に統合）

| 宣言 | 意味 | 旧タブでの対応物 |
|---|---|---|
| `visible_when` | method 等の条件で表示 | `*_visible` 群 |
| `label_by_mode` | 同じ param の**意味変化**をラベルで示す（例: `wall_probability` は markov 時 "Initial Probability"） | `probability_label` 連動 |
| `derived_default` | 切替時に連動して初期化される値 | shape 切替時の size/radius 充足 |
| `affects` | この項目を変えると連動して変わる項目の一覧（**headless に test 可能**） | evaluate_control_state 全体 |
| `asset_kind` | この param が消費する資産種別（§2） | —（新規。資産⇔node の依存を宣言） |

### 5.2 inspector の連動表示

- 切替時に「静かに隠す/出す」のではなく、**何が連動して変わったかが分かる遷移**を見せる（REPAIR-19 の method 切替行再描画の一般化）。
- **cross-node 依存**（例: `toric_passage` は square 入力でのみ意味を持つ、distribution 資産は wall_method=markov でのみ消費、Item Generator は上流 selection が定義域）: param 行に**由来 chip**（「この設定は上流 X / 資産 Y に依存」）として表示する。**gate / block にはしない**（R2-3 原則: 意味を持たない組合せは default へ静かに整合させ、依存の説明だけを示す）。
- これにより「設定 A を変えると何が変わるか」が UI 動線で追え、暗黙知の要求を解消する。

-> 安易なラベルによる説明はやめて欲しい。生成グラフとは別に、パラメータ種別の各項目に関する依存関係のグラフを可視化できないだろうか？必ずしもそうする必要はなく、デザインセンスを問う問題です。依存関係にある複数のノードは同時に設定項目を(それが管理しているノード含めて)表示するとか、多くの可能性があります。というか、グラフのノード自体が単体で存在できず他のノードに依存するべきにも見えるし、その時点で、ノードの生やし方のボタンから設計が間違っているように思います。オプショナルなノードと依存元となるノードの関係を明確にして、親パラメータが固定された後に別個のノードを生やせるとか、親パラメータを変えたら小ノードの名称が変わるようにするなどの設計もありえて、無数のデザイン提案の余地がある。重要な機能を目立たせる必要があり、Shapeが親なのは地味なので自明なパターンとして吸収させたい気持ちもある。

### 5.3 R2-4 回答の一般原則の適用

**「その画面で設定を変更できない項目は表示する意味がない」** — Context chips 等の表示専用要素は、撤去するか、その場で設定可能な UI に変換する。§5.2 の由来 chip は「クリックで該当上流 node / 資産 editor へ移動できる」**操作可能要素**として設計し、この原則に適合させる。

## 6. 画面導線への帰結（機能確定後の配置再確認）

- **Load Graph / Overwrite selected** は「graph 資産の operation」として §4 の文法（dropdown + Load/Save）へ統合し、header から外す。
- **graph template**: bundled graph preset の dropdown + 適用（旧 Profile 行を置換。Simple profile は template の一種）。
- **生成結果**: 名前付き保存 → **リスト**（thumbnail はやらない）→ 選択で viewport へ即時切替（data 込みなので再生成なし）→ そのまま promote 可能。
- Batch N / Seed randomize / Shape randomize は撤去（確定）。

## 7. 実装スライス案（本ドキュメント確定後に queue 化）

| # | slice | 内容 | 依存 |
|---|---|---|---|
| 1 | 置き場所規約 + presets service 二層化 | `<kind>` 汎用の bundled/project 二層 service。adjacency rules を移行して基準形を確立 | — |
| 2 | schema 中央化 = `REPAIR-21`（拡張版） | §5.1 の宣言（visible_when / label_by_mode / derived_default / affects / asset_kind）+ default 常時有効。headless schema test | — |
| 3 | wall distribution の資産化 | resource 参照 + preset root 読込 + V5 round-trip test | 1 |
| 4 | item pool の資産化 | `HexItemPoolResource` 新設 + editor 統合 | 1, 2 |
| 5 | 依存連動の inspector 反映 | §5.2 連動表示 + 由来 chip（操作可能） | 2 |
| 6 | 生成結果の保存/切替 | (b) data 込み・リスト・即時切替・promote 導線 | 1 |
| 7 | graph template + header 整理 | bundled graph preset / Profile 行置換 / Load Graph 等の移設 / batch 系撤去 | 1 |
| 8 | V6 runtime 同一性 | **reference 資産の runtime 解決**を含めた同一 seed 同一結果 test | 3, 4 |

## 8. 未決事項（round 2 への問い）

1. **Q-RM-1**: project asset の default root は `res://hex_map/<kind>/` で良いか（project setting 名: `hex_map_kit/asset_root` を想定）。-> 承認。
2. **Q-RM-2**: inline → 資産化の昇格導線は各 criteria editor window 内の「Save as asset」で良いか（inspector 行側にも出すか）。-> Save as assetで良い。inspectorは生成結果表示としては使用可能だが、Godot editor上の動作的にユーザー向け変更状態の可視化が保存処理の信頼性を損なっているので資産化の場面では気にしない。
3. **Q-RM-3**: 生成結果の data 込み保存で file が重くなるケースの扱い — そのまま保存（警告なし）/ 保存時にサイズ表示のみ / 上限警告。推奨: **サイズ表示のみ**（gate 的な干渉をしない）。-> 生成処理の重さとファイルサイズは関係ないはずなので気にしなくて良い。
