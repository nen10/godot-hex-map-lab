# DESIGN-11 SUB_TASKS

Complexity class: **C2**（navigation/IA の1 slice。code/state machine なし、fallback/mirror なし。decisions は概ね確定済み。）

## Task Resolution

`TAB_IA.md` を作る。内容＝**タブ集合/順序/改名・優先度分類・タブ間導線・workspace top strip 仕様**。`DESIGN-10` の per-tab 仕様（主役/primary action）を前提に、「どこから始めればいいか分からない」を解消する **global な進行表示**を定義する。Codex は確定仕様を文書化するのみ。

## Locked decisions（確定。再検討しない）

| 論点 | 決定 |
|---|---|
| 改名 | `Generate` → **`Build`** |
| QA/Validate | tab bar から外し **Diagnostics drawer**（park）。tab ではない |
| tab bar 集合・順序 | **Build, Paint, Catalog, Layers, Resources, Export, Settings**（7） |
| 分類 | Primary(Build/Paint) / Support=map semantics(Catalog/Layers/Resources) / Utility(Export/Settings) / Parked(QA,Validate) |
| 主導線 | Build → Paint → Export（top strip に表示） |
| 分類 vs 導線 | **別軸**（分類＝tab bar の重要度、導線＝作業順序。top strip が導線を見せる） |
| strip の二層 | **global top strip**（DESIGN-11）と **per-tab context strip**（DESIGN-10）を分離（重複させない） |

## Task Resolution Candidate Matrix

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 重要度の見せ方 | A: tab 順 + global top strip / B: TabContainer グループ化 | **A** | Godot 標準 TabContainer はグループ表示が弱い（draft §2.2） |
| Export 分類 | A: utility（導線終点） / B: primary | **A** | 創作反復面でなく handoff 終点。導線では最終 step として top strip に出す |
| QA/Validate 露出 | A: Diagnostics drawer / B: 末尾 tab 残置 | **A** | park の物理表現・主導線の視認性向上 |

## Scheduled Task Audit

scheduled task 追加: なし。

## Sub-tasks

1. tab bar 集合・順序・改名表。
2. 優先度分類表（Primary/Support/Utility/Parked）。
3. タブ間導線図（Document hub 中心）。
4. global top strip（workspace home）仕様 + ASCII。
5. global strip と per-tab context strip の責務分界。

fallback / mirror 有無: なし。
