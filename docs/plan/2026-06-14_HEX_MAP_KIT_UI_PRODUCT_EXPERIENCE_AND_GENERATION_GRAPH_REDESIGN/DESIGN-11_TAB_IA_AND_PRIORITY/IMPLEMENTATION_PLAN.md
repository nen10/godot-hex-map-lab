# DESIGN-11 IMPLEMENTATION_PLAN（pre-execution）

## Scope

`TAB_IA.md` を作る。**tab 集合/順序/改名・優先度分類・タブ間導線・global top strip 仕様**を確定文書化。code 変更なし。Codex は本仕様を文書化するのみ。

## 変更対象ファイル

```
docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/TAB_IA.md   （新規）
```

## 確定 IA 仕様（これを文書化する）

### 1. tab bar 集合・順序・改名

順序（左→右）: **Build, Paint, Catalog, Layers, Resources, Export, Settings**（7）。
改名: `Generate` → **`Build`**。
QA / Validate は tab bar に**含めない**（Diagnostics drawer・park）。

### 2. 優先度分類

| group | tabs | 役割 | tab bar 位置 |
|---|---|---|---|
| **Primary** | Build, Paint | 創作の主作業面 | 前方・強調 |
| **Support（map semantics）** | Catalog, Layers, Resources | 主作業を支える棚（語彙/構造/束縛） | 中間 |
| **Utility** | Export, Settings | handoff / 設定 | 後方 |
| **Parked** | QA, Validate | 観察のみ | tab bar 外（Diagnostics drawer） |

### 3. タブ間導線（Document hub）

```
   Catalog(語彙) ┐
   Layers(構造)  ┤  (support 棚)
   Resources(束縛)┘──► [ Level Document ] ◄── edit ── Paint
                              ▲   │
                  Build ─promote─┘   └── readout ──► Export (handoff)
   QA / Validate … observe only（Diagnostics drawer・parked）
```
主導線（作業順）: **Build → Paint → Export**。Support は Document hub を介して Build/Paint を支える。

### 4. global top strip（workspace home）

tab を跨いで常在。ASCII（凡例は `LAYOUT_SKETCH_POLICY.md` §4）:

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Map: Dungeon_01   Draft / Unsaved              Build ▸ Paint ▸ Export       │  # current step を強調
│ Missing: Tile Catalog       [Create Pipeline]  [Paint]  [Export]   [Diagnostics] │
└──────────────────────────────────────────────────────────────────────────┘
 ┌ Build ┐┌ Paint ┐  ┌ Catalog ┐┌ Layers ┐┌ Resources ┐  ┌ Export ┐┌ Settings ┐
   ‹primary›            ‹support: map semantics›             ‹utility›
```

top strip が持つもの:
- `Map: <name>` + 状態（Draft/Unsaved 等）
- 進行 `Build ▸ Paint ▸ Export`（current 強調）
- `Missing: <X>` ＋ 行動 CTA（未設定時）
- `[Diagnostics]`（parked QA/Validate を開く）

### 5. global strip と per-tab context strip の分界

| strip | 所有（task） | 内容 |
|---|---|---|
| global top strip | DESIGN-11 | Map / 状態 / 進行 / Missing CTA / Diagnostics |
| per-tab context strip | DESIGN-10 | そのタブ固有 chips（Catalog/Target/Layer/Brush 等）。`Map` は持たない（global と重複させない） |

## TAB_IA.md の構成（Codex への指示）

1. tab 集合/順序/改名表（§1）。
2. 優先度分類表（§2）。
3. タブ間導線図（§3, ASCII）。
4. global top strip 仕様 + ASCII（§4）。
5. global / per-tab strip 分界表（§5）。

## Dependency / Test Matrix（= acceptance proof）

| area | risk | proof |
|---|---|---|
| 分類表 | 優先度不明 | Primary/Support/Utility/Parked が全7+park を網羅 |
| 改名 | Generate 残存 | `Generate`→`Build` 明記 |
| 導線 | 順序不明 | Build→Paint→Export が図と top strip に出る |
| top strip | 始点不明 | Map/状態/進行/Missing CTA/Diagnostics を含む |
| 分界 | Map 二重持ち | global と per-tab の責務が重複しない |
| park | QA/Validate 露出 | tab bar に QA/Validate が無い（Diagnostics のみ） |

## Planned steps

1. §1–§5 を `TAB_IA.md` に文書化（表＋ASCII）。
2. DESIGN-10 の per-tab context strip と矛盾しないか分界表で確認。

## Planned completion criteria（二層 DoD）

- S: 分類表 + タブ間依存導線 + top strip 仕様 + 分界表。
- E: top strip 設計で「今の map / 進行 / 次の行動」がラベル説明なしで分かる（始点不明の解消）。
- test: code 非変更のため `./tools/test.sh` は回帰確認のみ（green）。
