# Hex Map Kit — 製品定義 (Product Definition)

確定日: 2026-06-15
ステータス: baseline（次期Roadmap・既存実装擦り合わせ・acceptance判定の参照元）
関連:
- 実行評価: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
- 次期Roadmap draft: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md`

---

## 0. 確定した基本判断 (locked 2026-06-15)

| 論点 | 判断 |
|---|---|
| 配布意図 | 再利用可能な Godot addon として**配布する製品**。個人利用は出発点だが、品質基準は「他者が再利用できる」水準に置く。 |
| 対象ジャンル重心 | **戦術 / ダンジョン系を第一**。戦略 / 盤面 / オーバーワールドは将来拡張。 |
| Simple Build と Graph | **Generation Graph が製品の背骨（本体）**。Simple Build は入口 (on-ramp)。 |
| Runtime の約束 | **「Godot へ渡す境界まで」**。clean に読み込める runtime node + 座標 / データ問い合わせ utility + **runtime Map Build API（graph resource を実行時に読み込み map を生成）** まで。ゲームプレイ層（戦闘 / AI / ターン進行 / 勝敗）はユーザー責任。 |
| QA / Validate の扱い | **park（棚上げ）**。製品の目標機能ではない。自律的に存続・発展してよいが、中心化・全体への波及（侵食）はさせない。定量品質観察の価値は Generation Graph に包摂される。慣習基準による概念検証レンズとしてのみ任意利用可。 |

---

## 1. 一行定義

Godot 4 で、ゲーム（まず戦術 / ダンジョン系）に使える hex マップを、**手続き生成と手編集を行き来しながら組み上げ、Godot ランタイムへ clean に引き渡す**ための、配布可能な editor addon。

## 2. 対象ユーザーと job-to-be-done

- **誰が**: Godot で hex ベースの戦術 / ダンジョン系ゲームを作る個人〜小規模開発者。
- **何をしたい**: 空の状態から、ゲームの土台となる hex レベルを一気に組み上げ、自分のゲームへ渡したい。
- **今なぜ困る**: 生成が単発で、中間レイヤーを次の生成に繋げられない。画面が「設定ファイル管理」に見え、どこから着手するか分からない。

## 3. 製品の背骨（これがある＝この製品を使う理由）

生成は **Markov Mesh 型の確率パラメータ生成**で、数値確率の違いだけで「部屋状を含むマップ」「迷路状のマップ」等の基本形状を表現し、意味論的 fallback として**通路生成を後段で**行う（＝細かな手編集なしで基本形状が立つ）。手編集 (Paint) は、純ランダムでは不便なデザイン管理を補う層。

ただし単発の一次生成だけでは、地形 Tile や game object（アイテム配置等）を**多様な形状にまたがって一貫した基準で管理する**のが難しい。そこで本体は——**複数の生成方式で作った layer を pipeline で合成し、一貫した生成基準による terrain / object 配置を、形状の違いを越えて実現する node graph editor**。これがこの製品を「単なる hex 生成ライブラリ」と分ける一点であり、Simple Build は入口、Graph が本体。

## 4. 主導線（この順で価値が流れる）

```
Build (生成graph: 複数生成方式layerを一貫基準で合成 → terrain/object配置)
  → Paint (デザイン管理のための手編集・仕上げ)
    → Export / Handoff (Godotへ渡す境界)
```

- Export のゴールは「runtime scene で正しく読み込め、座標問い合わせできる状態で渡す」こと。**“遊べるゲーム” の完成ではない**（そこから先はユーザーのゲーム実装）。Handoff は3形態 — **(a) data resource(.tres)** / **(b) scene(layer node tree .tscn)** / **(c) generation graph resource（runtime Map Build API で実行時生成）**。
- `Catalog / Layers / Resources` は導線を支える棚であって主役ではない。`Settings` は samples / debug / preferences。
- **QA / Validate は主導線に含めない（§0・§7 の park 扱い）。** 複数マップの定量観察という価値は、graph editor（編集した基準に基づく再生成＝完全上位互換）に包摂される。

## 5. ドメイン名詞モデル（コードに実在するもので固定）

| 概念 | 役割 | 実体 |
|---|---|---|
| HexTileMap (node) | 作業の起点（選択対象） | scene node |
| Level Document | その map 固有の真実 | `HexMapDocumentResource` |
| Tile Catalog / Object DB | 共有アセット（catalog key 参照） | `HexTileCatalogResource` 他 |
| Layer Stack | terrain / overlay / object / debug の役割 | `HexLayerStackResource` |
| map semantics | cell に意味を与える { 語彙 / 構造 / 束縛 } | **Catalog**(語彙: key) + **Layers**(構造: role/writable) + **Resources**(束縛: 使用 .tres) |
| Generation Graph | 生成 pass の連鎖（**新規・背骨**）。著作物かつ出荷可能 | MVP: Dictionary → `HexGenerationGraphResource` |
| Runtime substrate | Godot へ渡す境界 | `HexTileMapLayer` + 境界 utility（読み込み / 表示 / 座標 / path・range）+ **runtime Map Build API**。**gameplay framework ではない** |

## 5.1 map semantics と Build / Paint の関係

`map semantics` = { Catalog(語彙) / Layers(構造) / Resources(束縛) }。cell に意味を与える共有座標系。

Build(graph) と Paint は、ともに map semantics を消費して `cell →（key, role）` を同じ Level Document に書く点で**同じ**。違いは：

| 軸 | Build (graph) | Paint |
|---|---|---|
| 単位 | 方式 / ルール（手続き・大量） | 個別インスタンス（手作業・1セル） |
| semantics の使い方 | 生成ルールの param / 対象 | 現在の筆（active key / active role） |
| 出力 | regenerable（再生成 → promote） | authored delta（確定編集） |
| 入り方 | promote（`generated` 層） | direct write（`document` / 手動 層） |

**共存の鍵**: Layer role の `writable source`（`generated` / `document` / `target` / `readonly`）が生成層と手描き層を分け、**再生成が手作業を潰さない境界**になる。

## 6. スコープ境界

- **In**: 生成 graph（複数生成方式 layer の一貫基準合成）/ 手編集 / map semantics(catalog / layer roles / resources) / Godot handoff（data resource / scene / **graph resource + runtime Map Build API**）/ sample 学習 / 配布パッケージ。
- **Out（ユーザー責任 or 当面やらない）**: ゲームプレイ実装（戦闘 / AI / ターン / 勝敗）、analog / 手動テスト、public package upload 自動化、v1 スキーマの主役化、戦術 / ダンジョン以外へのジャンル特化。

## 7. Non-goals（意図的に追わない）

- gameplay framework になること（runtime はあくまで “渡す境界”）。
- 綺麗なデモ画面それ自体（手段であって目的でない）。
- **metric / test 通過を製品品質の代理にすること（明示的に禁止）。**
- **QA / Validate を製品価値の中心に据えること、またその効果を全体へ波及（侵食）させること。** これらは本体（生成 graph）と目標機能を共有しない。自律的に存続・発展してよいが、製品方向を駆動させない。価値は graph editor に包摂され、本来目標を閉ざさない限り独立価値は生じない。慣習基準による概念検証（PoC）レンズとしてのみ任意利用可。

## 8. 成功定義（proxy ではなくユーザー成果で判定）

1. 開発者が**一度の作業で**「空 → 生成 graph で複数生成方式 layer を一貫基準で合成（terrain + object 配置）→ paint で仕上げ → Godot runtime scene で正しく読み込み・表示・座標問い合わせできる状態で書き出す」を完走できる。
2. dock を開いた最初に、各 tab が「何をする面か」**ラベルを読まずに**分かる。
3. 中間出力を次 pass の入力に**実際に繋げられる**（背骨が機能している）。
4. addon として他プロジェクトに導入し、上記が再現できる（配布品質）。
5. 上記が回帰なく繰り返せる（**metric はここの回帰検知のみ**担当）。

## 9. 配布品質の含意（配布する製品であるため）

- 公開 API（`HexTileMapLayer` 等）と catalog / document Resource の形が安定し、ドキュメント化されている。
- samples は「導入直後に動く学習素材」として機能し、production asset と混ざらない。
- packaging（dist / manifest）は最終工程で再生成。通常 test gate にはしない。
