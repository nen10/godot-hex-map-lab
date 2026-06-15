# SCREEN-41 SUB_TASKS

Complexity class: **C3**（既存 layers screen をテキスト要約から role stack 視覚化へ。）

## Task Resolution
Layers を **role stack の視覚化**にする（DESIGN-10 Layers 仕様）。現状はテキスト要約 + form。terrain/overlay/object/debug role が視覚的に並び、writable/visibility/lock を chip/toggle で扱う。

## 確定設計（DESIGN-10）
- 主役: role stack visual tree（各 role 行に visible/lock/writable-source/z の chip、並べ替え可）。
- chips: `Map:` `Layer Stack:`
- inspector: 選択 role の writable source(document/target/generated/readonly)/z/visible/lock。
- empty: `[Create Layer Stack] [Choose Layer Stack]`。

## Scope
含む: role stack 視覚化、chip/toggle、選択 role 編集、並べ替え。
含まない: layer データモデル変更（既存 `HexLayerStackResource`）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 表示 | A: 視覚 stack / B: テキスト要約 | **A** | 現状の弱点を是正（U1）|
| 属性 | A: chip/toggle / B: テキスト | **A** | 一目で状態 |

## Scheduled Task Audit: なし。
## Sub-tasks
1. role stack visual tree。
2. 各 role の visible/lock/writable/z を chip/toggle。
3. 選択 role inspector 編集。
4. empty CTA。
5. tests。
fallback/mirror: なし。
