# Layout Sketch Policy

確定日: 2026-06-15
ステータス: policy（screen 実装前の layout sketch / wireframe の作り方を規定）
関連:
- `docs/design/PRODUCT_DEFINITION.md`（タブの主役・map semantics・主導線）
- `docs/design/GENERATION_GRAPH_MODEL.md`（Build tab の graph anatomy）
- `docs/ui/WORKSPACE_UI_CONTRACT.md`（禁止text/no-op/scroll/debug label＝**回帰ガード**。本書とは別レイヤー）
- `docs/process/QUEUE_OPERATION_RULES.md`（two-layer DoD：sketch は experiential DoD の design-time 版）

---

## 0. 目的とスコープ

- **目的**: screen 実装前の design artifact（layout sketch / wireframe）を、迷わず・一貫して作れるようにする。`wireframe-before-code` と experiential DoD の **design-time 版**。
- **適用範囲**: `Build / Paint / Export / Catalog / Layers / Resources`（`Settings` は utility として最小適用）。**QA / Validate は park（適用外）**。
- **スコープ（A=軽量）**: sketch 記法 + 必須リージョン + 構成規則のみ。**比率(%)・dock幅応答などの数値規定はしない**（数値 proxy は前回の失敗要因。支配度は質的に判定）。

---

## 1. タブ・レイアウトの解剖（必須リージョン）

各 work tab の sketch は次のリージョンで構成する。

```
┌──────────────────────────────────────────────────────────┐
│ context strip:  ( Map: … ) ( Catalog: … ) ( Target: … )   │ ← map semantics は chips（詳細row禁止）
│                                          [ Primary Action ] │ ← 頭出し1つ
├──────────────────────────────────────────────────────────┤
│                                                            │
│              PRIMARY WORK SURFACE  (dominant)              │ ← そのタブの主役（最大面積）
│                                                            │
├──────────────────────────────────────────────────────────┤
│ selected inspector  (条件付: 選択要素を持つタブのみ)        │
└──────────────────────────────────────────────────────────┘
```

| region | 必須/条件 | 中身 | 禁止 |
|---|---|---|---|
| context strip | **必須** | map semantics の chips（Map / Catalog / Target role 等）、primary action | 詳細 resource row の列挙、内部語彙 |
| primary work surface | **必須** | そのタブの主役（§2） | 先頭をラベル列・resource row にすること |
| primary action | **必須** | 頭出し1つ（例 `[Generate]`） | 無差別に並ぶボタン群 |
| empty state | **必須**（別図） | 行動 CTA | 「No X / Not selected」ラベル列 |
| selected inspector | 条件付（選択型タブ） | 選択要素の detail と、その要素への action | 常時の resource 一覧 |
| resource 詳細の退避先 | 必須記載 | drawer / `Resources` tab / context chips | work tab 先頭への配置 |

---

## 2. 各タブの主役（dominant work surface）

主役は製品定義が決める（`PRODUCT_DEFINITION.md` §4）。sketch はこれを最大面積で描く。

| tab | 主役（work surface） |
|---|---|
| Build | generation **graph canvas** + output preview |
| Paint | 2D **viewport + brush palette**（active layer/cell/last edit） |
| Catalog | tile/object の **visual asset board** |
| Layers | **role stack** の視覚ツリー |
| Resources | 選択中 map の **asset shelf**（Unique/Shared/Optional）※ここだけ resource が主役で可 |
| Export | **purpose cards**（handoff 3形態） |
| Settings | グループ + toggle（utility・最小適用） |

---

## 3. レイアウト規則

1. **Work surface first（質的）**: 主役が dominant region で、**resource 詳細より前**に来る。比率は数値で縛らず「主役が一番大きく・最初に見える」で判定。
2. **Primary action は1つ**を目立つ位置（context strip 右 か 主役上部）。
3. **Resources are context**: 詳細 row を先頭に並べない。chips / drawer / `Resources` tab へ。
4. **Empty state は CTA**（次の行動）。説明ラベル列にしない。
5. **Label budget は質的**: 許容＝heading / primary-action ラベル / chip / warning / tooltip に逃がせない短 status。退避＝型説明・policy・debug state・queue/test 由来語・user action に直結しない readiness summary（debug drawer へ）。
6. **map semantics は chips** で示し、編集は `Resources` に送る。
7. **1 sketch = normal + empty の2状態**を必ず描く。

---

## 4. 記法（ASCII notation）

凡例:
- `┌─┐ │ └─┘ ├─┤` … box / region 分割
- `[ Action ]` … button（primary は context strip 右 or 主役上部）
- `( Key: value )` … context chip（map semantics）
- 主役領域は**最大面積**で描き、内部に主役の要素（node 群 / brush palette / card grid / role tree 等）を示す
- `# 注記` … 「→ drawer」「primary」「empty variant」等を脇に明記

各 sketch のヘッダに明記する: **tab名 / 主役 / primary action / resource 退避先**。

---

## 5. 他 doc との関係（重複させない）

- `WORKSPACE_UI_CONTRACT.md` … **出荷時の欠陥回帰ガード**（禁止 text / no-op button / scroll / debug label）。本 policy は**設計時の構成**を規定し、UI_CONTRACT は**出してはいけないもの**を規定する。**別レイヤー・参照のみ**。
- `PRODUCT_DEFINITION.md` … タブの主役・map semantics・主導線の定義元。
- `GENERATION_GRAPH_MODEL.md` … Build tab（graph canvas）の anatomy。
- `QUEUE_OPERATION_RULES.md`（two-layer DoD）… sketch は experiential DoD（最初に見えるもの / 触れる primary action）を**設計時点で満たす**こと。

---

## 6. 適用チェックリスト（`DESIGN-10` 等で使用）

各タブ wireframe は次を満たすこと:

- [ ] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [ ] 主役が dominant で、resource 詳細より前に来る
- [ ] primary action が1つ明確
- [ ] empty state が CTA（ラベル列でない）
- [ ] label budget 準拠（内部語彙なし）
- [ ] normal + empty の2状態を描いた
- [ ] （選択型タブ）inspector が選択要素を表示
- [ ] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない
