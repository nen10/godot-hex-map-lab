# SCREEN-30 SUB_TASKS

Complexity class: **C3**（Build tab の simple/graph 両立 + preview/promote/dirty の仕上げ。）

## Task Resolution

`GRAPH-11/12/13` で出来た Build canvas を、**初心者（Simple）と上級者（Graph）が1画面で両立**する完成形にする。Simple は **preset graph**（mode 切替にしない）。両入口が最初の画面から辿れる。

## 確定設計
| 論点 | 決定 |
|---|---|
| Simple の実体 | Generation Profile を選んで `[Generate]` → 内部で **preset graph**（shape→wall→connectivity を profile param で）を生成・実行・terrain promote |
| Graph の実体 | 既存 canvas（`GRAPH-11`）。Simple で出来た preset graph をそのまま編集に開ける |
| 両立 | canvas が主役。上部に Simple 帯（Profile picker + Generate）。Simple↔Graph は同じ graph を指す |
| 見える状態 | preview / promote 先 role / dirty・last run |

## Scope
含む: Simple 帯（profile→preset graph→generate）、canvas との一体化、preview/promote/dirty の仕上げ、tests。
含まない: graph model/canvas 自体（既存 GRAPH-11..13）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| simple/graph | A: preset graph で統一 / B: 別 mode | **A** | 二重 UI 回避（PRODUCT_DEFINITION「simple は入口」）|
| Simple の出口 | A: preset graph を canvas に出す / B: 隠す | **A** | 上級へ地続きに昇る |

## Scheduled Task Audit: なし。

## Sub-tasks
1. preset graph factory（Generation Profile → 基本 graph）。
2. Simple 帯 UI（profile picker + `[Generate]`）。
3. canvas との一体化（Simple 生成 graph を canvas で編集可能に）。
4. preview/promote 先/dirty の表示仕上げ。
5. tests。

fallback/mirror: なし。
