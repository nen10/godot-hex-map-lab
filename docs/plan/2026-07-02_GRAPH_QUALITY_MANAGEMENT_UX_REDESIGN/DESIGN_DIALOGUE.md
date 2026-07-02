# Graph 品質管理 UX 再設計 — 設計対話 (round 1)

日付: 2026-07-02
状態: **design dialogue draft**（ROADMAP 化の前段。本ドキュメントをユーザーとやりとりして刈り込み・確定し、`ROADMAP.md` → queue へ落とす）
関連:
- `docs/design/PRODUCT_DEFINITION.md`（§0/§3/§4/§7 — 本ドキュメントはこれを画面構成へ具体化する。矛盾しない）
- `docs/design/GENERATION_GRAPH_MODEL.md`
- `docs/development_log/2026-07-02_OLD_GENERATE_EXECUTION_DEPENDENCY_MODEL_DECISIONS.md`（確定済み判断。REPAIR-19/20 実装済み、REPAIR-21/22/23 queue 済み）

---

## 0. 前提の確定文（2026-07-02 ユーザー共有）

1. マップ生成の背骨は **Markov Mesh 型のランダム生成**であり、「部屋のような形状をいくつか含むマップ」「迷路のような形状のマップ」を**数値化された確率パラメータ設定の違いだけ**で表現する。**通路生成を後段で行う**ことで意味論的な堅実さを確保し、基本的なマップ形状自体を細かな編集なしに成立させる。
2. ランダムのみの生成過程はゲーム開発上の**デザイン管理として不便**なため、**Paint がその補完**として必要（authored delta）。
3. 一次生成だけではアイテムのランダム配置等の管理がしにくいため、**複数の生成方式で作られた layer を合成する pipeline 生成方式**により、さまざまな形状のマップで**一貫した生成基準による地形 Tile / ゲームオブジェクト配置**を実現する。これが graph パイプラインエディターの存在理由。
4. **QA / Validate 画面の本質的価値（複数マップの品質の定量観察）は、生成パイプラインを表示する node graph editor によって代替されている。**「編集した指標に基づいた Map 生成」は、観察→手直しの分離した品質管理に対する**完全上位互換**である。
5. この品質管理機能を効果的に機能させるには、**まだ機能不足と UI/UX 上の欠陥が多い**。過去に COMPLETE となった項目にも**実態が怪しいものがある**。

## 1. 設計原則 — 奥深さとシンプルさのメリハリ

「本質的で奥深さとシンプルさのメリハリがある UX」を、以下の運用可能な規律に落とす:

- **奥深さを置く場所（depth budget の投下先）**: 生成基準の編集とその帰結の観察・比較。すなわち graph の中——node の method 別 criteria（markov distribution / adjacency rules / seeds / compose policy）、node 出力の観察、run 間の比較。深さは **progressive disclosure**（inspector 行 → 専用 window）で提供し、**tab・常設パネルを増やして提供しない**。
- **シンプルに保つ場所**: tab の役割一義性（ラベルを読まずに何の面か分かる）、各面の primary action は 1 つ（Build=Generate / Paint=筆 / Export=書き出し）、Simple(on-ramp) は入口のまま拡張しない。
- **採否判定**: 新しい UI 要素は「品質管理 loop（§2）のどの段を強化するか」を一言で言えなければ採らない。言えても、既存要素の深化（window/badge/既存面への内挿）で足りるなら新設しない。

## 2. Build 面の再定義 — 品質管理 loop

graph 画面は「生成の設定画面」ではなく、**編集 → 生成 → 観察 → 比較 → 確定** の品質管理 loop そのものである。各段の現状と欠落（コード実態で裏取り済みの範囲）:

| loop 段 | 現状（実態） | 欠落・欠陥（候補） |
|---|---|---|
| **編集**（基準） | inspector param 行 + Markov window + Adjacency Rules window（磨き込み進行中）+ rule preset .tres 群（作業中） | 方式依存 schema が inspector に散在（→`REPAIR-21`）。criteria の resource 化（preset 保存/共有）が adjacency 以外に無い |
| **生成** | async run + progress relay + cache/dirty + cancel | dirty 伝播の実態未検証（param 変更→downstream 再計算の配線: →V1）。semantic gate 不在（→`REPAIR-22`） |
| **観察** | **選択 node のサムネイル 1 枚**（`selected_preview_snapshot`）+ viewport projection | node 単位の観察可能性が無い: 出力 cell 数 / wall 率 / 連結成分数 / item 数等の **node badge**、失敗・空出力 node の可視化 |
| **比較** | Batch N + Seed/Shape randomize（secondary 配置） | **N 結果を並べて見る面が存在しない**（batch の結果がどこへ行くかも要検証: V9）。「編集した指標で再生成して比べる」の"比べる"が最後の 1 枚でしか成立していない |
| **確定** | Promote(role 指定) / Apply / Revert（REPAIR-10 契約） | generated / document 境界の可視化、promote 済み layer と graph の対応の見え方 |

**この表の「欠落」列が拡張候補の母集合**。§5 の inventory はここから展開し、round 2 で刈り込む。

## 3. 画面構成の整理（提案）

現状の tab row: `Build / Paint / Catalog / Layers / Resources / Validate / QA / Export / Settings`（9 tabs）。

主導線（PRODUCT_DEFINITION §4: Build → Paint → Export）に対して、**QA / Validate が主 tab の一等地を占めているのは前提 4 と不整合**。提案:

| 層 | tabs | 扱い |
|---|---|---|
| 主導線 | Build / Paint / Export | 左端に連続配置。価値の流れの順 |
| 棚（semantics） | Catalog / Layers / Resources | 主導線の後ろ。役割は現状どおり |
| 周辺 | Settings | samples / debug / preferences |
| park | Validate / QA | **tab row から降格**。案A: 非表示（Settings 内 toggle で opt-in 表示）/ 案B: Settings 配下へ移設 / 案C: 現状維持（並び順のみ末尾へ） |

- park 方針（自律存続・中心化禁止・波及禁止）との整合: 降格は「存続」と両立する。削除はしない。
- **→ 未決 Q1**: 降格方式 A/B/C の選択。


Build 面内の構成は、canvas + inspector + 下部 run bar という骨格は維持し、**観察（node badge）と比較（batch 結果の見え方）をどこに内挿するか**が論点（→ Q2/Q3）。面としての新設はしない方針（§1 の規律）。

意見 : 何の機能を担うのかがUXとして明確に実現され機能的な意義を明確にしてから、どこに置くか検討してください

## 4. VERIFY track — 「COMPLETE だが実態が怪しい」項目の検証

過去 COMPLETE 項目を、能書きでなく probe で再確認する。各項目は「何が真なら合格か」を先に固定する:

| id | 対象 | 検証内容（真であるべきこと） | probe |
|---|---|---|---|
| V1 | GRAPH-13 dirty 伝播 | inspector param 変更 → 該当 node が dirty → downstream のみ再計算。cache 誤再利用が無い | headless: runner `dirty_node_ids` 配線を canvas/screen 経由で検証する test | -> 細かい改善は重要だが、そんなレベルではない構造的なUX問題を優先して対処しなければ本質的な問題を後回しにしてしまう。UXが明確になった後に行えば十分。重要度最後尾に位置する。
| V2 | REPAIR-16 typed filter ports | editor drag 層で overlay→Overlay Filter が結べ、terrain→Overlay Filter が弾かれる | `tools/probe_region_filter_connection_typing.gd` 再実行 | -> どうでも良い。論理層とUI層がもつアダプターの違いを理解していない Godot の GDScript 初心者の発想。
| V3 | REPAIR-10 Apply/Revert | 連続 Generate / Revert 後再 Generate / graph-less layer bootstrap の縁ケースで表示と document が一致 | editor test + 実描画キャプチャ | -> 検証する分には軽そうなので構いません。これを検証する以前の構造的欠陥が多く、このような検証に辿り着くことが僕にはできませんでした。問題が判明したとしても修正優先度は最後尾です。
| V4 | SCREEN-30 Simple↔canvas 同一モデル | Simple 生成の graph が canvas に見え、同一 model である（`simple_and_graph_same_model`） | snapshot 検証 + 目視 | -> 検証する分には軽そうなので構いません。仮に問題が判明しても無視して進んでください。修正優先度は最後尾です。
| V5 | GRAPH-14 resource round-trip | 新 param（`toric_passage` / `custom_distribution` / structured `probability_rules` / `limit`）が save/load round-trip で完全保存 | round-trip test 拡張 | -> 良いと思います。進めてください。 `custom_distribution` はadj.ruleのように個別のファイルで管理し、既存distributionはプリセットファイルのルートをcustom内で新設して読み込み可能とするなどAdj.ruleと比較してUXレベルで統一感を持たせたいです。共通のUX改善を行います。また、各パラメータは不快感なくUIに反映される必要があります。グラフィカルなスキルを活用して検証します。
| V6 | RUNTIME-50 runtime build 同一性 | 同一 graph resource + 同一 seed で editor 生成と runtime 生成が一致 | 既存 test の対象 param 拡張 | 
| V7 | 走査 parity / markov custom parity | perf branch 再設計後の bias 実態（=`REPAIR-23`、queue 済み） | 監査 + 回帰 test | -> UX上の意義が不明確であり優先度最後尾
| V8 | REPAIR-17/18 window UX | COMPLETE 表記に対し手直しが継続している。UX 完成の定義を明文化して再判定 | 実描画キャプチャ + experiential DoD |
| V9 | Batch N の結果先 | N>1 実行時に結果がどこへ行き、ユーザーは何を見られるか（比較 UX 設計の前提事実） | build_screen 実挙動確認 | -> 1生成で十分理想的なマップを生成するために、このアルゴリズムと生成フローを設計しているため、コンセプト原理的に不要な機能。優先度最後尾。

**運用**: V 項目は「修理」でなくまず「事実確認」。falsified なら §5 の inventory に修理 task として昇格。

## 5. 拡張候補 inventory（草案 — round 2 で刈り込む）

loop 段ごと。◎=背骨に直結 / ○=有効 / △=価値はあるが depth budget と要相談:

| 段 | 候補 | 効果 | メモ |
|---|---|---|---|
| 編集 | ◎ `REPAIR-21` param schema 中央化 | criteria 編集の基盤。UI 非依存・headless test 可能 | queue 済み | -> 明確に進めます
| 編集 | ○ criteria の resource 化の一般化 | adjacency rule set .tres（進行中）と同型で markov distribution / item pool を preset 化 | 「編集した指標」を持ち運べる資産にする | -> 重要
| 生成 | ◎ `REPAIR-22` semantic run gate | 空 rules / 空 pool 等を実行前に node 粒度で可視化 | queue 済み | -> 全ての項目はデフォルトで埋まっているはずで、全体的な意義がよくわからない。
| 生成 | ○ V1 の帰結（dirty 修理） | 反復速度＝品質管理 loop の回転数 | V1 次第 | -> 
| 観察 | ◎ node 出力 badge | node 直上に cell 数 / wall 率 / 連結成分数 / item 数。「定量観察」の graph 内蔵化（QA 価値の包摂を実体化する中核） | 常時表示は最小 2〜3 指標、詳細は選択時 | -> 情報量過剰なので表示するノードは制限する。ItemGenerationノードの個数制限・重みなどの設定の効果を明確化するため、生成項目数とその割合の表示に限っては有用。ただし、同一レイヤー内での割合はともかく、レイヤーを跨いだ意味での割合は概念的な混乱を招く可能性があるため深入りせず、機能に対する実需要を受けてからさらなる詳細は検討する。
| 観察 | ○ 失敗・空出力 node の可視化 | gate と対で「なぜ出ないか」を graph 上で | REPAIR-22 と統合可 | -> 中間レイヤーは生成マップ結果本体には含まれない。出ないと出さないをユーザー意図から区別できないため混乱を招く。実需要を受けてから検討する。
| 比較 | ○ batch 結果の最小比較面 | N 結果の thumbnail 並置 + 選択→viewport 投影 + そのまま promote | 旧 seed lab の score tree は復活させない（park 判断済み）。**見る→選ぶ**だけの最小形 | -> サムネイル表示は原理的によくわからない。以前四角タイルのよくわからない出力結果が画面内に並置され、Hexタイルマップと何の関係もないお気持ち表示が自己主張してグラフ領域を圧迫し迷惑だった。サムネイルの実現可能性が不明なので生成のリストで十分。大サイズマップになると基本的に生成コストが重いので扱いが危険になる。
| 比較 | △ run 間 diff（前回 run との差分表示） | 指標編集の帰結を直接見る | 強力だが実装コスト大。round 2 で要否判断 | -> パラメータ調整による1マップ生成の繰り返しに対して意味を持ち、有用性を感じる。リソースとして保存して切り替えるだけなのでは？そもそものリソースファイルの管理設計から合理化して欲しい。
| 確定 | ○ promote 済み layer ↔ graph 対応の可視化 | 「この layer はこの graph から」の追跡 | Layers 面 chip との連携 |
| 横断 | △ graph template（rooms / maze / …の開始点） | on-ramp 強化 | Simple との役割重複に注意 | -> 良いと思う。現状のheaderには意味不明な項目が多すぎてUXを損なっているため、一掃してこのような本質的な機能によって既存項目を押しつぶすことの利得が大きすぎます。

## 6. 既 queue 項目の位置づけ（本フレームへの折り込み）

- `REPAIR-21`（schema 中央化）= loop **編集**段の基盤
- `REPAIR-22`（semantic gate）= loop **生成**段の guardrail
- `REPAIR-23`（走査 parity 再監査）= **観察・比較の信頼性の前提**（V7 と同一）
- `REPAIR-12`（中間出力 child nodes）= loop **観察**段（中間出力を壊さず見る）に再文脈化

## 7. 未決事項（round 2 への問い）

1. **Q1: QA/Validate の降格方式** — 案A（非表示 opt-in）/ 案B（Settings 配下）/ 案C（末尾へ並び替えのみ）。推奨: A（park の「中心化禁止」を画面構成でも明示する）。 -> どうでもいい
2. **Q2: 比較 UX の最小形** — batch N の結果を (a) thumbnail 並置面（Build 内下部/横）/ (b) viewport 逐次切替のみ / (c) 当面なし（V9 の事実確認後に再判断）。推奨: V9 → (a) の最小形。-> どうでもいい
3. **Q3: node badge の常時表示粒度** — 常時 = 出力 cell 数 + 型、選択時 = wall 率 / 連結成分 / item 内訳、まで絞るか。もっと薄く/濃くするか。-> 上で提案したように、ItemGenerationノードの最小限に絞る
4. **Q4: inventory の刈り込み** — §5 の ○/△ の採否と順序。特に「run 間 diff」と「graph template」。-> △の項目のような本質的な提案をもっと多く聞きたい。刈り込むべきところは他に多い。
5. **Q5: VERIFY track の実行順** — 推奨: V9・V1（比較/反復の前提事実）→ V5・V6（資産の完全性）→ V2〜V4・V8。 -> それぞれ記載した。認識に大きくズレがあることが判明したため、擦り合わせを進めましょう。

---

round 1 の主張の要約: **「graph = 品質管理面」を実体化する最短経路は、面の新設ではなく、(1) 観察の graph 内蔵化（node badge）、(2) 比較の最小形（batch 並置）、(3) 編集基盤の中央化（REPAIR-21/22）、(4) 既存 COMPLETE の実態検証（VERIFY track）である。**

---
---

# Round 2 (2026-07-03) — 概念の修正と再提案

round 1 への回答（本文中の `->` 注記）を受けた擦り合わせ。まずズレを明文化し、軸を差し替え、提案を出し直す。

## R2-0. 認識のズレの明文化

- **round 1 の誤読**: 「品質管理」を下流の管理——多数生成 → 観察（badge 乱立）→ 比較（batch 並置）→ 検証（VERIFY 大量）——で実体化しようとした。これは park したはずの **QA 的発想の裏口からの再輸入**だった。タブ配置論も「機能の UX 意義が確定する前の配置論」で順序が逆。
- **修正後の理解**: 本製品は **1 回の生成で理想のマップが出る**ことを、アルゴリズム（Markov Mesh + 通路後段）と生成フローの設計で保証するコンセプト。したがって品質管理とは、**上流の基準（criteria）を視覚的に編集し、資産（resource file）として保存・使い回し・差し替えること**。下流の観察・比較は最小限に留め、実需要が観測されてから深める。
- **順序の規律**: 機能が担う UX とその意義を先に確定し、配置（タブ・面・位置）はその後に検討する（§3 への指摘を規律化）。

## R2-1. 修正後の軸 — 基準（criteria）のライフサイクル

**作る（visual editor）→ 保存する（file 資産）→ 使い回す（preset）→ 差し替える（切替）→ 確定する（promote）**

criteria 種別ごとの現状（2026-07-03 コード裏取り）は非対称で、これを **adjacency rules の形に揃える**のが軸:

| criteria | visual editor | file 資産化 | preset | 現状評価 |
|---|---|---|---|---|
| adjacency rules | window（磨き込み中） | `.tres`（進行中） | dropdown + `assets/adjacency_rule_presets/` | **基準形（これに揃える）** |
| markov distribution | window | **×**（graph params に dict 埋込。`custom_distribution_resource` の受け口は存在するが UI 未接続） | 組込み ID（Ilands/Maze/Discrete）のみ | file 化・「preset を root として custom へ読込」が無い |
| item pool | inspector 行のみ | × | × | editor・資産化とも最弱 |
| graph 全体 | canvas | `HexGenerationGraphResource` | ×（template 無し） | header に junk（R2-4） |
| 生成結果 | viewport 投影 | `HexGenerationResultResource`（promote 用途のみ） | — | 名前付き保存・切替が無い |

**resource 参照の中核価値**: criteria が file 資産になると、graph param は値の埋込ではなく **資産への参照**にできる。同じ rule set / distribution を複数 node・複数 graph で共有し、資産側の編集が全参照点へ波及する——「編集した指標」が単一の source of truth になる。これが「編集した指標に基づいた Map 生成」の資産面の実体。

## R2-2. 採用提案（回答を反映した確定リスト・この順で進める）

| 順 | 提案 | 根拠（回答） | 規模 |
|---|---|---|---|
| 1 | **REPAIR-21 param schema 中央化**。「default 常時有効」原則（R2-3）を schema の責務に含める | 「明確に進めます」 | queue 済み・着手可 |
| 2 | **criteria resource 管理の統一設計**: custom_distribution の個別 file 化 + 既存 preset を root として custom に読込・item pool の preset 化・置き場所/命名/sample-production 分離の規約・embed vs reference 整合・adjacency rules と同一の操作文法（Preset dropdown + Save/Load） | 「重要」「そもそものリソースファイルの管理設計から合理化して欲しい」 | **別紙 `RESOURCE_MODEL.md` を round 3 で起こす規模** |
| 3 | **header 一掃 + graph template**: 意味不明項目の撤去と、rooms / maze 等の template を primary 位置へ（R2-4 に棚卸し） | 「一掃して本質的な機能で押しつぶす利得が大きすぎる」 | 中 |
| 4 | **生成結果の resource 保存/切替**: run 間比較の正体。名前付き保存 → 一覧（リスト表示。thumbnail はやらない）→ 切替 | 「リソースとして保存して切り替えるだけなのでは」 | 中（保存内容は Q-R2-3） |
| 5 | **Item Generation node badge（最小）**: 生成項目数とレイヤー内割合のみ。他 node には出さない。レイヤー跨ぎ割合は概念混乱を招くためやらない。実需要を受けて再検討 | 回答どおり | 小 |
| 6 | **V5 + V6**: 資産の round-trip 完全性 / runtime 同一性 test（提案 2 と同じ列車で） | 「良いと思います。進めてください」 | 小 |
| 7 | **V8**: REPAIR-17/18 window の完成定義 =「各パラメータが不快感なく UI に反映される」を DoD 化し、実描画キャプチャで判定 | 回答（V5 注記の「グラフィカルなスキルを活用して検証」を DoD に昇格） | 小 |

## R2-3. REPAIR-22 の再 scope 提案: 「semantic gate」→「default 常時有効」

回答「全ての項目はデフォルトで埋まっているはずで、全体的な意義がよくわからない」を原則化する:

- **全 param は default で充足され、default のまま Generate しても常に有効な生成が走る**。
- 空 rules / 空 pool のような「実行を止めるべき状態」は、gate で検出するのではなく**構成不能にする**（adjacency は default preset、pool は default entry を schema が保証）。
- したがって gate UI・block reason バッジは**作らない**。REPAIR-22 は独立 task として廃止し、この原則を REPAIR-21（schema 中央化）の acceptance に統合する。queue の書き換えは round 3 確定後に実施。

## R2-4. header 一掃の棚卸し（機能の意義 → 残否。配置はその後）

現状の Build 上部（コード実態）: ① Context chips（text 詰め込み）/ ② Load Graph / ③ Overwrite selected checkbox / ④ **Generate** / ⑤ Profile dropdown + Generate (Simple) の 2 行 + 下部 action row の ⑥ Batch N / ⑦ Seed randomize / ⑧ Shape randomize / ⑨ Apply / ⑩ Revert / ⑪ status。

| 項目 | 担う機能 | 提案 |
|---|---|---|
| ④ Generate / ⑨⑩ Apply・Revert / ⑪ status | 生成と確定の primary | **残す** |
| ⑤ Profile + Generate (Simple) | on-ramp | **template に統合**（Simple profile は template の一種。R2-2-3） |
| ⑥⑦⑧ Batch / Seed randomize / Shape randomize | 多数生成→比較 | **撤去**（V9 回答: 1 生成で理想を出すコンセプトに原理的に不要。`GENERATION_GRAPH_MODEL.md` §5 の「半オプション」判断を上書き → Q-R2-2） |
| ② Load Graph / ③ Overwrite selected | graph 資産の読込・上書き | 機能は必要だが header の一等地の意義は無い。**resource model（R2-2-2）の導線として再設計**し header から外す |
| ① Context chips | 文脈表示 | 情報の要否から再検討（resource model と同時） | -> 一般原則:その画面で設定を変更できない項目は表示する意味がない により、撤去または移動して設定可能UI化する

## R2-5. 最後尾 parking（回答理由の記録）

| 項目 | 理由（回答の要旨） |
|---|---|
| V1 dirty 伝播 | 細かい改善より構造的 UX 問題が先。UX 確定後で十分 |
| V2 typed ports | 論理層と UI 層のアダプター差異の理解の問題であり、検証課題ではない |
| V3 Apply/Revert 縁ケース / V4 Simple↔canvas | 検証は軽いので可。問題が出ても修正は最後尾 |
| V7 / REPAIR-23 走査 parity | UX 上の意義が不明確。最後尾（queue status 変更は round 3 で） |
| V9 batch 結果先 / 比較面 | コンセプト原理的に不要（1 生成で理想）。thumbnail 並置は過去の悪例（四角タイルの無関係表示が graph 領域を圧迫）+ 大サイズ生成コストの危険。一覧が要るなら**リストで十分** |
| 失敗・空出力 node の可視化 | 中間レイヤーは生成結果本体に含まれず、「出ない」と「出さない」をユーザー意図から区別できない。実需要待ち |
| Q1 QA/Validate 配置 / Q2 比較 UX | どうでもいい（機能の意義確定が先） |

## R2-6. Round 3 への問い（3 つに絞る）

1. **Q-R2-1（resource model の骨子）**: R2-2-2 を別紙 `RESOURCE_MODEL.md` として起こす。対象は adjacency rules / markov distribution / item pool / graph / 生成結果 の 5 種で、規約は「置き場所・命名・sample/production 分離・preset root・embed vs reference・共通操作文法（Preset dropdown + Save/Load）」。**この骨子で書き始めて良いか。他に資産化したい criteria はあるか。** ->資産化はこのままで良いが、設定項目及びassetごとの、生成方式決定のためのノードグラフ内での核依存関係がUX動線としてUIにわかりやすく反映される必要があり、一つの項目を設定したときに、他の項目が連動して変わる上階繊維モデルによる管理機能が旧Generateタブから十分に引き継がれておらず、ユーザーに暗黙知を必要とする設定変更作業を過剰に要求した状態に現状なっているため、このこと含めて(schema 中央化と並んで)明確さを与えられるように改善する必要がある。
2. **Q-R2-2（batch 系の撤去）**: Batch N / Seed randomize / Shape randomize を UI から完全撤去し、`GENERATION_GRAPH_MODEL.md` §5 の「半オプション（N 生成）」判断を上書きして良いか（runner の複数 run 能力自体は headless に残る）。-> それで進める。この機能自体は実需要後に設計すれば十分であり、開発上の理念に関与しないため先回りした提供は不要。
3. **Q-R2-3（生成結果 resource の保存内容）**: (a) graph snapshot + seed のみ（軽い・切替時に再生成が走る）/ (b) 出力 data 込み（切替が即時・大マップの再生成コストを回避・file は重い）。**切替の即時性を優先するなら (b) 推奨**（thumbnail 否定の理由「大サイズ生成コスト」と整合）。-> (b)で進める

---

# Round 3 (2026-07-03) — 確定記録と成果物

round 2 への回答により以下を確定し、反映した:

| 確定事項 | 反映先 |
|---|---|
| 資産化 5 種の骨子で進める + **依存連動（状態遷移）モデルの継承**を中核要求に追加（設定・asset の核依存関係を UX 動線に反映し、一項目の設定で他項目が連動更新。暗黙知の要求を解消。schema 中央化と並置） | `RESOURCE_MODEL.md` §0-4/§5（連動モデル）+ `REPAIR-21` acceptance 拡張 |
| Batch N / Seed randomize / Shape randomize は UI から完全撤去（実需要後に設計で十分。理念に関与しない先回り提供は不要） | `GENERATION_GRAPH_MODEL.md` §5 上書き注記 |
| 生成結果 resource は (b) 出力 data 込み | `RESOURCE_MODEL.md` §2/§6 |
| REPAIR-22 廃止（default 常時有効原則として REPAIR-21 へ吸収） | queue: `SUPERSEDED` |
| REPAIR-23 最後尾降格 | queue: `BACKLOG` + 選択禁止注記 |
| 一般原則「その画面で設定を変更できない項目は表示する意味がない」（R2-4 Context chips 回答） | `RESOURCE_MODEL.md` §5.3（由来 chip は操作可能要素として設計） |

**round 3 の成果物**: `RESOURCE_MODEL.md`（draft round 1）。未決は同 §8 の Q-RM-1〜3（project asset root / 昇格導線 / result file サイズ表示）。確定後に実装スライス（同 §7）を queue 化する。
