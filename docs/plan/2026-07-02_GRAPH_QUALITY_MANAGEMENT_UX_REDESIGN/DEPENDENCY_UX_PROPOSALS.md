# 依存駆動の graph authoring — デザイン提案（round 1）

日付: 2026-07-03
状態: **design proposal**（`RESOURCE_MODEL.md` §5.2 の差し替え。「由来 chip」案は撤回する）
関連:
- `RESOURCE_MODEL.md`（§5.1 schema 宣言は本提案の基盤として維持）
- `docs/policy/LAYOUT_SKETCH_POLICY.md`（リージョン解剖に準拠）
- `docs/design/PRODUCT_DEFINITION.md` §5.1（Build/Paint と layer の関係）

---

## 0. 課題の再定義

round 2 §5.2 の「由来 chip」は、**依存を説明する UI** だった。依存を説明しなければならないのは、**依存を構造にできていない**からである。本提案は問いを差し替える:

> 「依存関係をどう表示するか」ではなく、**「編集面そのものを依存の形にするにはどうするか」**。

現状の palette 方式（Add Node ボタン → 単体 node 出現 → 手動配線）の構造的欠陥:

1. **この graph に単体で存在できる node はほぼ無い**。全ての非 root node は親（入力）を要求する。にもかかわらず作成 UI は「単体で作って、後から繋ぐ」——存在できないものを作らせてから、繋ぎ方の暗黙知を要求している。
2. 型不一致・未配線・「次に何を作れるのか分からない」は、この作成文法から**構造的に**発生する。REPAIR-16（typed ports）のような修理はこの文法の欠陥の対症療法だった。
3. 旧 Generate タブが持っていた連動（1 つの設定変更が関連設定を同時に変える）は、「全設定が 1 枚のパネルに同居していた」から可能だった。node に分割した瞬間に同居が壊れ、連動も壊れた。**分割の単位が間違っている**。

## 1. どの方向でも採る共通決定（回答の 5 つの種を確定に昇格）

| # | 決定 | 由来 |
|---|---|---|
| C1 | **palette（単体 Add Node）を廃止**。作成は常に既存の依存元から「**生やす**」 | 「ノードの生やし方のボタンから設計が間違っている」 |
| C2 | **Shape を node から廃止**し、terrain 系譜の**台紙（自明なパターン）**として吸収 | 「Shape が親なのは地味なので自明なパターンとして吸収」 |
| C3 | **親 method が確定してから、それに従属する子（criteria 資産・派生層）が生やせる**。親を変えたら子は名称・フィールドごと**見えるように morph** する | 「親パラメータが固定された後に別個のノードを生やせる」「親パラメータを変えたら小ノードの名称が変わる」 |
| C4 | **依存関係にある一群の設定は同時に表示**する（単 node inspector を依存 group inspector に置換） | 「依存関係にある複数のノードは同時に設定項目を表示」 |
| C5 | **目立たせるのは criteria 資産の名前と層の名前**（ユーザーの著作物）。配管・自明な構造は沈める | 「重要な機能を目立たせる」 |

## 2. 方向A（本命）: 系譜レーン — 「graph の node」をやめて「層の生成系譜」にする

### 2.1 コンセプト

この製品の本体は「複数の生成方式で作った **layer** を合成する pipeline」である。ならば Build の作業面は「node の集合」ではなく、**層の生成系譜（lineage）**であるべきだ。**lane（レーン）= 将来の layer と 1:1 対応**させる:

- **terrain lane（基幹・常に 1 本・最初から存在）**: 台紙=Shape 設定（lane header に吸収）。その上に **壁（Wall Field）→ 通路（Connectivity）** が精製 stage として乗る。旧 Generate タブの primary 生成そのもの。
- **item lane（0..n 本・ユーザーが生やす）**: 「どの範囲に（定義域 tap + scope）」「どの方式で（generator method）」「何を（item 名 = 層の名前）」。1 本が 1 つの overlay 層になる。
- **layer stack panel（右端・確定面）**: lane の出力が層として積まれる。積み順と write policy がここの属性（= Compose の吸収）。層ごとに promote。Result node は消える——**stack panel が Result である**。

### 2.2 wireframe（LAYOUT_SKETCH_POLICY 準拠）

```
┌ Build ─────────────────────────────────────────────────────────────────────┐
│ context strip: (Map: dungeon_a) (Template ▾)              [ Generate ]      │
├───────────────────────────────────────────────────────────┬────────────────┤
│ PRIMARY WORK SURFACE: 生成系譜                              │ Layer Stack    │
│                                                           │ (確定面)        │
│ ▛ terrain ▟   台紙: Square 21 ▾                            │                │
│   ├─ 壁     [Markov Mesh ▾]  (dist: "Maze+" ▾)             │ ■ terrain      │
│   └─ 通路   [Dense ▾]  toric ☑                             │   [Promote]    │
│      │                                                    │ ■ treasure     │
│      ├─⇢ floor ────▶ ▛ treasure ▟ [Limited ▾]              │   add_item ▾   │
│      │               (pool: "loot_small" ▾)                │   [Promote]    │
│      │                                                    │ ■ doors        │
│      └─⇢ wall ∩ edge ▶ ▛ doors ▟ [Adjacency ▾]             │   add_item ▾   │
│                        (rules: "on_entrance" ▾)            │   [Promote]    │
│                                                           │                │
│  [+ 層を生やす]                                             │                │
├───────────────────────────────────────────────────────────┴────────────────┤
│ selected inspector: 選択 lane の全設定（親子同時表示・morph はここで起きる）    │
└─────────────────────────────────────────────────────────────────────────────┘
```

- **太字で目立つもの（C5）**: lane 名（= 層名）と criteria 資産 chip（`"Maze+"` / `"loot_small"` / `"on_entrance"`）。chip は RESOURCE_MODEL §4 の editor window を開く**操作可能要素**（表示=設定可能原則）。
- **沈むもの**: Shape（台紙表記）、配線（tap 分岐 glyph `⇢ floor` のみ。自由曲線の wire は存在しない）。

### 2.3 「生やす」の文法（C1/C3）

- `[+ 層を生やす]` → **(1) 定義域を選ぶ**（tap picker: `terrain.floor` / `terrain.wall` / `treasure.cells` / `document.overlay` … **型が合う origin しか出ない**ので型不一致が構成不能）→ **(2) 方式を選ぶ**（Weighted / Limited / Adjacency）→ lane が default 充足状態で出現（**即 Generate 可能** = default 常時有効の構造化）。
- **criteria 子は親 method に従属して生える（C3）**: `Markov Mesh` を選んだときだけ distribution chip が生え、`Adjacency` を選んだときだけ rules chip が生える。方式を変えると **chip が名称ごと morph** する（`pool: "loot_small"` → `rules: "on_entrance"`）——「親を変えたら子の名称が変わる」の直訳。
- **scope builder（Set Operation の吸収）**: 定義域は tap の式（`wall ∩ edge`、`floor \ treasure.cells`）として lane header 内で編集。自由 node としての Set Operation は消える。

### 2.4 旧 Generate タブとの関係 — 連動モデルの正統継承

旧タブは「**terrain lane 1 本 + overlay lane 1 本**の特殊形」だったと再解釈できる。連動（symmetric ⇔ markov ⇔ toric、overlay ⇔ adjacency XOR limit）が機能していたのは全設定が 1 枚に同居していたからであり、lane はこの同居を**系譜 1 本ごとに**復元する（C4: lane 選択 = 親子設定の同時表示）。連動の実体は schema 宣言（`visible_when` / `label_by_mode` / `derived_default` / `affects`、RESOURCE_MODEL §5.1）が供給し、lane 上の morph として可視化される。**graph の一般性（lane n 本・lane 間 tap）を得た上で、旧タブの連動を取り戻す。**

### 2.5 底層は変えない（実現可能性の要）

lane は **authoring 文法（view）** であり、persistence と実行は既存のまま:

- lane 構成 ⇄ 既存 Dictionary graph / `HexGenerationGraphResource` は**双方向に機械変換可能**（lane = 直線 chain + tap edge の集合。terrain lane = Shape→Wall→Connectivity chain、item lane = Filter→ItemGenerator chain、stack panel = Result + promote_targets）。
- runner / dirty cache / runtime Map Build API / headless test は**無変更**。
- **検討点（正直に）**: 既存資産に lane で表現できない任意 DAG（例: compose の入れ子木）が存在した場合の扱い。案: (a) 読込時に正規化（stack 順序へ展開）/ (b) 残余を「advanced 系譜」として折り畳み表示。→ Q-DEP-2。

## 3. 方向B（漸進形）: 現 canvas に「生やす」文法を導入

GraphEdit canvas を維持したまま C1〜C5 を適用する:

- palette 廃止。**node の出力 port から「ここから生やす ▾」**（型に合う候補だけが出る: terrain からは 壁/通路/Filter、selection からは Item Generator…）。
- node 選択 → inspector が**依存 group（上流 chain の関連設定込み）を同時表示**。
- 親 method 変更 → 従属 node の title / criteria chip が morph。
- Shape は「新規系譜の開始」action に吸収（canvas 空状態 = terrain 系譜が default で 1 本立つ）。

**評価**: A への足場として成立し、リスクが低い。ただし wire と自由配置が残るため「依存の形をした編集面」は完成しない（node を離れた場所に置ける自由は、この domain では暗黙知の温床でしかない）。

## 4. 方向C（検討の上、非推奨）: パラメータ依存の第二グラフ可視化

回答で示された「生成グラフとは別に、パラメータ依存関係のグラフを可視化」を検討した:

- この domain の依存は**浅く局所的**（method→param 群、param→隣接 param、資産→stage、上流→定義域）。長距離・非局所の依存網（spreadsheet 的）ではないため、独立グラフが本領を発揮する構造ではない。
- 表示専用の第二グラフは「表示=設定可能」原則に反する。編集可能にするなら、それは**依存の形をした編集面**——つまり突き詰めると方向Aに収束する。**C の成熟形が A である**、というのが本検討の結論。
- ただし schema の `affects` 宣言（機械可読の依存表）はどの方向でも保持する。headless test の対象であり、将来別視点の可視化が必要になった時の基盤になる。

## 5. 比較と推奨

| 軸 | A: 系譜レーン | B: 生やす文法のみ | C: 依存第二グラフ |
|---|---|---|---|
| 暗黙知の解消 | ◎ 構成不能化+同居復元 | ○ 作成は解決、配置自由が残る | △ 説明が増えるだけ |
| 奥深さ/シンプルさのメリハリ | ◎ 資産と層名が主役 | ○ | × 学習物が増える |
| 旧タブ連動の継承 | ◎ 構造で継承 | ○ inspector で継承 | △ |
| product 概念との一致 | ◎ **lane=layer**（§5.1 の道具立てそのもの） | △ node のまま | △ |
| 実装コスト | 中（ただし GraphEdit を捨てられる分、B より軽い可能性あり） | 中（GraphEdit の制約と戦う） | 中 |
| 資産互換 | ○（変換 + 検討点あり） | ◎ | ◎ |

**推奨: A を直行で採る。** B は「A の途中成果物」としてすら GraphEdit 依存が重く、経由する利得が薄い。lane view は VBox ベースの素直な widget 構成で作れるため、GraphEdit と戦い続けるより軽い見込み。

## 6. RESOURCE_MODEL への波及（方向確定後に反映）

- §5.2 を本提案で差し替え（chip 案撤回）。
- §7 実装スライスを改訂: slice 5「依存連動の inspector 反映」→「**lane view（系譜レーン）の実装**」に置換し、slice 7（header 整理）は lane 化に吸収（template = 台紙+系譜の bundled preset。Load Graph/Overwrite は graph 資産 operation として §4 文法へ）。
- Node palette / GraphEdit canvas / Shape node / Set Operation node / Compose node / Result node は **UI 概念としては廃止**（graph model 内では存続し、lane との相互変換で使う）。

## 7. 未決（round 2 への問い）

1. **Q-DEP-1**: 方向 A 直行で確定して良いか（B 経由の段階案を捨てる）。→ **round 2 で回答済み（A 続行・ただし中間系譜の取りこぼしを是正）**
2. **Q-DEP-2**: lane 非表現の既存 graph 資産の扱い — (a) 読込時正規化 / (b) advanced 系譜として折り畳み。推奨: (a)（現実の資産は GRAPH-12 系の直線 chain が支配的で、正規化の損失が実質無い）。
3. **Q-DEP-3**: terrain lane の壁・通路 stage は「常設（method に none を含む）」か「生やす対象」か。推奨: **常設**（旧タブの primary 生成の骨格は自明なパターンであり、生やす操作の対象は創作物である item lane と criteria 資産に限る——C5 のメリハリ）。

---

# Round 2 (2026-07-03) — 中間生成系譜の一級化

方向 A への回答:「方向性は非常に良い。ただし**中間生成レイヤーは多用される前提**であり、添付のグラフ構造（2 系統の Shape→Wall、素材側の item 生成×2、Overlay Filter→Set Operation 木→マップ側 Item Generator→Result）が**マップ生成の基本形**」。round 1 の「lane = layer と 1:1」はこの基本形を取りこぼしていた——**Result に届かない系譜こそが中心的な運用**である。モデルを次のとおり改訂する。

## R2-1. 修正: lane = 系譜。「出力」は lane の定義ではなく属性

- **lane（系譜）** = 生成の血統（台紙+stage、または 定義域+生成方式）。これが編集の単位。
- **出力 lane**: Layer Stack に積まれる lane（terrain 1 本 + 任意数の item lane）。stack panel に現れ、promote できる。
- **素材 lane（中間生成・一級市民）**: どの stack にも積まれず、**他 lane の定義域の材料**としてのみ消費される系譜。terrain 系（第 2 の Markov パターン等）も item 系（seed 配置等）も作れる。**多用される前提で、出力 lane と同じ文法・同じ場所で編集する**（隠さない・二級にしない）。
- **素材 ⇔ 出力は相互変換可能**（lane header の出力 toggle）。実験として作った素材を後から層に昇格できる。

## R2-2. tap 語彙と定義域式（Filter / Set Operation の完全な溶解）

- **tap 語彙**: あらゆる lane の出力を selection として参照できる — `<lane>.floor` / `<lane>.wall` / `<lane>.cells` / `<lane>.item(key)`。Terrain Filter も Overlay Filter も node ではなく **tap の型変換**として消える。
- **定義域式**: item lane の定義域は tap の式 — 例（基本形そのもの）:
  `terrain.floor ∩ (seeds_a.cells ∪ seeds_b.cells)`
  Set Operation の**木**（画像の SetOp→SetOp 入れ子）は式の**括弧**として表現される。wire の visual トレースより、式 1 行のほうが読解・編集とも強い（chip 単位で操作可能: tap chip クリック = 参照元 lane へジャンプ/ハイライト、演算子は dropdown）。
- **再利用は参照で**: 同じ tap（例 `pattern_b.floor`）を複数 lane の定義域が参照してよい（DAG 性は式の参照で保たれる。wire は不要）。

## R2-3. 基本形の翻訳表（添付グラフ → lane model）

| 画像の node 群 | lane model での姿 |
|---|---|
| Shape → Wall Field → Connectivity → Result.terrain | **出力 terrain lane** `terrain`（台紙 + 壁 + 通路。stack の terrain） |
| Shape → Wall Field（下段・Result 非接続） | **素材 terrain lane** `pattern_b`（台紙 + 壁。通路 = None） |
| Terrain Filter（下段）→ Item Generator ×2 | **素材 item lane** `seeds_a` / `seeds_b`（定義域 = `pattern_b.floor`。同一 tap の 2 回参照） |
| Overlay Filter ×2 → Set Operation（下）→ Set Operation（上）← Terrain Filter（上） | 出力 item lane の**定義域式**: `terrain.floor ∩ (seeds_a.cells ∪ seeds_b.cells)`（Overlay Filter は `.cells` tap に、SetOp 木は式の括弧に溶ける） |
| Item Generator（右上）→ Result.overlay_0 | **出力 item lane** `items`（stack に積まれ promote 可能） |
| Connectivity.terminals port | 通路 stage の optional `terminals` tap 指定 |

**13 node + 12 edge が、系譜 5 本 + 式 1 行になる。** 情報は失われない（双方向変換可能）が、暗黙知（どこに何を繋ぐか）は式と tap 語彙に置き換わる。

## R2-4. 画面（改訂 wireframe）

```
┌ Build ──────────────────────────────────────────────────────────────────────┐
│ (Map: dungeon_a) (Template ▾ 基本形)                            [ Generate ] │
├──────────────────────────────────────────────────────────────┬──────────────┤
│ マップ（出力）                                                  │ Layer Stack  │
│ ▛ terrain ▟  台紙: Square 21 ▾                                 │ ■ terrain    │
│   ├─ 壁   [Markov ▾] (dist: "Maze+" ▾)                         │  [Promote]   │
│   └─ 通路 [Dense ▾] toric ☑                                    │ ■ items      │
│      └─⇢ floor ∩ (seeds_a.cells ∪ seeds_b.cells)               │  add_item ▾  │
│                ▶ ▛ items ▟ [Adjacency ▾] (rules: "r1" ▾)       │  [Promote]   │
│                                                              │              │
│ 素材（中間生成 — stack に積まれない）                             │              │
│ ▛ pattern_b ▟  台紙: = terrain ▾(連動)                          │              │
│   └─ 壁 [Markov ▾] (dist: "Islands" ▾)   通路 [None ▾]          │              │
│    ├─⇢ pattern_b.floor ▶ ▛ seeds_a ▟ [Weighted ▾](pool ▾)      │              │
│    └─⇢ pattern_b.floor ▶ ▛ seeds_b ▟ [Weighted ▾](pool ▾)      │              │
│  [+ 生やす ▾]（出力層 / 素材系譜）                                │              │
└──────────────────────────────────────────────────────────────┴──────────────┘
```

- 帯は **マップ（出力）上・素材 下**（画像の primary 上段・素材 下段の読み順と同じ）。
- **素材 lane の台紙は default で出力 terrain と連動**（`= terrain`。上書き可）——依存連動（derived_default）の実例。基本形では両者同サイズが自然なため。
- **素材 lane の観察**: lane 選択でその系譜の出力を viewport に一時投影（`REPAIR-12`「中間出力を壊さず見る」の lane 版として再文脈化）。
- **生やす**は 2 種: 「出力層を生やす」（定義域→方式）と「素材系譜を生やす」（terrain 素材 or item 素材）。定義域式 builder の中から「ここで素材を生やす」も可能（需要から生える）。

## R2-5. Generate の一本化

回答の指摘どおり、現 Generate の fallback 動作は Generate (Simple) と実質同義。改訂後は:

- **Generate は 1 つ**: 全系譜（素材含む）をトポロジ順に実行し、出力 lane を viewport / stack へ投影する。fallback という概念は消える（空状態でも出力 terrain lane が default 充足で存在するため、常に有効な生成が走る = default 常時有効）。
- Simple / Profile 行は廃止（既定）。**基本形（本 round の添付構造）を bundled template の筆頭**にし、Template ▾ から 1 操作で系譜一式（素材込み）が立つ。

## R2-6. round 3 への問い

1. **Q-DEP-4**: 素材 ⇔ 出力の変換 UI は lane header の toggle で良いか（stack panel への drag でも可にするか）。→ **round 3 で解消**（Result への接続有無がトポロジとして表現するため、toggle 自体が不要になった）
2. **Q-DEP-5**: 定義域式の編集 UI — chip 式 builder（tap chip + 演算子 dropdown + 括弧）で良いか。式が長くなる場合の折り返し/名前付き部分式（`mask_1 = seeds_a.cells ∪ seeds_b.cells` を素材 selection として命名保存）まで初期スコープに含めるか。→ **round 3 で解消**（Set Operation は node として存続し、node 名がそのまま「名前付き部分式」になる）
3. **Q-DEP-6**: 素材 terrain lane の台紙は「出力 terrain と連動 default」で良いか。→ round 3 モデルでも有効な問いとして持ち越し（Q-DEP-9）

---

# Round 3 (2026-07-03) — GraphEdit 続投・統合 4 ノード・無型 edge・内部 adaptation

回答:「こう眺めると Graph エディターの方が視覚的に有用。**TerrainGeneration / ItemGeneration / Set Operation / Result の 4 ノードに統合**し、**UI 上の edge 型制約は行わず（一色）**、結びつきに応じて**内部的に adaptation の論理対応**を進める設計は Godot 的に可能か。設定項目依存はノード内で完結できる気がする。**Godot 上の UI 表現管理と論理処理のズレが設計の盲点としてボトルネック**。公式ドキュメントを踏まえて丁寧に。依存関係をノードと edge で表現し切りたい」。

## R3-0. 受け止め — lane 案から何が生き残るか

lane 案の本質的価値は帯 UI ではなく**統合の単位**だった。「系譜の設定は同居する」が TerrainGeneration / ItemGeneration ノードの**ノード内 cascade** として生き残り、素材系譜の再利用トポロジ（多用される中間生成の流れ）は GraphEdit の DAG 表示が最も雄弁に見せる——この分業を受諾する。

**設計原則（ズレの構造的解消）**: ズレは「同じ意味を 2 箇所で符号化する」（UI の port type id と論理層の accepts）ときに生じる。本設計は **UI 側の型符号化を撤去**し、意味論を論理層の adaptation に**一元所有**させる。UI が持つのは「接続の事実（nodes / edges / 行の adaptation 選択）」だけ。REPAIR-16 で踏んだ罠（論理は繋がるのに editor で繋げない）は同期の失敗ではなく二重符号化の帰結であり、片方を消すのが正答。

## R3-1. 統合 4 ノード

| node | 吸収する旧 node | ノード内で完結する設定依存（schema 駆動 = REPAIR-21 拡張版） |
|---|---|---|
| **Terrain Generation** | Shape + Wall Field + Connectivity + Source(terrain 系) | 台紙（shape / document / map resource / prior result）⇔ 壁 method ⇔ distribution 資産 ⇔ 通路 method ⇔ toric——旧タブ cascade の全体 |
| **Item Generation** | Terrain/Overlay Filter + Item Generator + Source(overlay 系) | 定義域 adaptation ⇔ placement method ⇔ criteria 資産（pool / rules）⇔ method 別 field |
| **Set Operation** | Set Operation（+「名前付き部分式」の役割） | op（∪/∩/∖）・各入力の adaptation。**node 名 = 部分式の名前**（`mask_1` 等） |
| **Result** | Result + Promote 導線 | substrate 自動判別・overlay 積み順（接続順・行で並べ替え）・write policy・promote |

基本形（round 2 添付・実測 15 node / 16 edge。R2-3 の 13/12 は誤記）はこの統合で **7 node / 9 edge** になる。Filter 2 種と Source と Shape は node として消滅する。

## R3-2. 無型 edge と adaptation（全域関数にする）

- **UI**: 全 port を単一 type id（0）・単一色に設定。公式仕様「Two ports can be connected if they share the same type」により、**型制約は自然消滅**する（追加 API 不要）。edge は一色。
- **論理**: 接続の意味は**消費側 input の adaptation** が決める。これを**全域関数**にする——どの接続にも定義された意味がある＝「型エラー」という概念が消える:

| producer 出力 | Item Generation.定義域 | Set Operation.入力 | Terrain Generation.terminals（任意） | Result.入力 |
|---|---|---|---|---|
| terrain | floor（既定）/ wall / any / item(key) | floor(既定) / wall / any | floor 等 → selection | substrate（最初の 1 本。以降は「未使用」を行に明示） |
| overlay（Item Generation 出力） | cells（既定）/ item(key) | cells（既定）/ item(key) | cells 等 → selection | overlay layer（接続順に積む） |
| selection（Set Operation 出力） | そのまま | そのまま | そのまま | —（意味を持たないため「未使用」明示） |

- adaptation は **input 行に埋め込む dropdown**（`floor ▾` / `cells ▾`）として常時可視・変更可能。旧 Filter node は「依存が発生するその場所」に溶けた——**依存関係をノードと edge で表現し切る**の実体。
- **唯一の構造制約は循環**: `connection_request` 受理時に既存 `HexGenerationGraph.topological_order` で循環検査し、循環を作る接続だけ拒否（＋`_is_node_hover_valid` で drag 中も抑制）。「無効状態は構成不能に」原則の接続版。

## R3-3. Godot 実現性（公式ドキュメント確認・2026-07-03）

`GraphEdit` / `GraphNode` の stable クラスドキュメントで以下を確認済み:

| # | 公式仕様 | 本設計での利用 |
|---|---|---|
| 1 | 「Two ports can be connected if they share the same type, or if the connection between their types is allowed in the parent GraphEdit（`add_valid_connection_type`）」 | 全 port を type 0 に統一 → 制約なし接続。追加 pair 登録は不要になる |
| 2 | `connection_request` / `disconnection_request` は**アプリが `connect_node()` を呼ぶまで何も起きない**（接続ロジックは完全に開発者に委譲） | adaptation 確定と循環検査の**単一介入点**。現 canvas は既にこの signal を受けている（`hex_map_build_graph_canvas.gd` L85-88, L766） |
| 3 | 循環防止は**組み込みでは存在しない** | 既存 `topological_order` を接続時に再利用（新規実装は薄い） |
| 4 | `_is_node_hover_valid()` virtual で drag 中の接続可否を注入できる | 循環になる hover を drag 中から抑制 |
| 5 | GraphNode は「子 Control ＝ slot 行」で、**任意の Control（OptionButton 等）を行として埋め込める**。`set_slot` で行ごとに port を有効化 | **adaptation dropdown を input 行に内蔵**。現 canvas は既に `set_slot` 運用（L242） |
| 6 | `get_titlebar_hbox()` で titlebar に任意 Control を追加可能。`set_slot_custom_icon_*` / `_draw_port` で port 描画も差し替え可能 | titlebar に criteria 資産 chip（`dist: Maze+` 等）・node 名編集。将来の描画調整の余地 |
| 7 | 1 入力 port への複数接続は仕様上禁止されない（アプリ層の管理） | 現行どおり connection_request で単一接続を維持（結合は Set Operation の役割） |

**結論: 可能。しかも現行より簡素になる。** 現 canvas は type id 割当・valid pair 管理・型別色を自前で持っているが、これらを**削除**して type 0 統一 + adaptation 行に置き換える方向であり、GraphEdit と戦う要素はない。UI 層から型が消えるため、REPAIR-16 型の「editor 実挙動 probe」も不要になる（意味論は headless の adaptation test だけで固定できる）。

## R3-4. lane 案からの継承リスト

- ノード内 cascade（＝ REPAIR-21 拡張版の schema がそのまま TerrainGeneration / ItemGeneration の中身）
- criteria 資産 chip の一等地表示（node titlebar。RESOURCE_MODEL §4 の editor window へ）
- **素材/出力の区別は「Result への接続の有無」がトポロジとして表現**（素材 lane の toggle は不要になった）。Layer stack panel は Result node の中身の展開（Result 選択時 or 右 panel）
- Generate 一本化・基本形 template・header 一掃・batch 撤去（round 2 決定は全て有効）
- 名前付き部分式 = Set Operation node の名前（Q-DEP-5 の解消）
- node 選択 → 中間出力の viewport 一時投影（REPAIR-12 の再文脈化、多用される素材系譜の観察手段）

## R3-5. round 4 への問い

1. **Q-DEP-7**: Source 系（document / map resource / prior result）の吸収先——Terrain Generation の台紙 mode + Item Generation の定義域 source mode で良いか（Source node の廃止）。
2. **Q-DEP-8**: Result の substrate 規則——「最初に接続された terrain が substrate、2 本目以降の terrain は行に『未使用』明示」で良いか。
3. **Q-DEP-9**: adaptation の既定値は terrain→`floor` / overlay→`cells` で良いか。素材 Terrain Generation の台紙 default を出力側と連動させる案（旧 Q-DEP-6）はこのモデルでも有効か。
