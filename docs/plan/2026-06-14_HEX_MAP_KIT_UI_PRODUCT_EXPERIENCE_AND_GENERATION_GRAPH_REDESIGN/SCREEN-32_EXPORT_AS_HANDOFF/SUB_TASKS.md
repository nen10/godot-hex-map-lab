# SCREEN-32 SUB_TASKS

Complexity class: **C3**（既存 `hex_map_export_screen.gd` を 3形態 purpose card へ。`RUNTIME-50` の graph card 依存。）

## Task Resolution
Export を製品定義の handoff 境界に厳密化。DESIGN-10 Export 仕様（purpose cards 3形態）に従う。

## 確定設計（DESIGN-10 / PRODUCT_DEFINITION）
purpose cards:
- `Runtime Map Resource (.tres)` `[Export .tres]`（HexTileMapLayer が load）
- `Runtime Scene (.tscn)` `[Create Scene]`（layer node tree）
- `Generation Graph (.tres)` `[Export Graph]`（runtime Map Build API 用, `RUNTIME-50`）
- 下段（副次）: Debug Report / JSON Snapshot / Package(process-only, disabled+tooltip)
頭出し: Runtime Map Resource card の action。

## Scope
含む: 3 card + 下段副次、目的から選ぶ導線、empty CTA、destination drawer。
含まない: package build の editor 実装（process-only）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 提示 | A: purpose cards / B: destination 一覧 | **A** | 「何のため」で選ぶ |
| package | A: process-only disabled card / B: 機能化 | **A** | EXPORT-NEXT-10 決定（process-only）|

## Scheduled Task Audit: なし。
## Sub-tasks
1. 3 purpose card（data/scene/graph）。
2. 下段副次（debug/json/package）。
3. empty CTA / destination drawer。
4. tests。
fallback/mirror: なし。
