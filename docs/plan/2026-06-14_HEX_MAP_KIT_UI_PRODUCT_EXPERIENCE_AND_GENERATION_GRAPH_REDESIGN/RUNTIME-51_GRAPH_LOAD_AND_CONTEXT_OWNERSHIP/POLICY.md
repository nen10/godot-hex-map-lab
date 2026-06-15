# RUNTIME-51 POLICY

## 採用方針
- **独立 context-owner を新設しない**: graph を「node の生産者」にし、文脈所有は既存の選択追跡へ集約。
- **embed vs reference の使い分け**: 新規=embed（自己完結）/ overwrite=reference・merge。
- **overwrite 安全弁**: `writable source` 準拠で `generated` 層のみ置換。
- 既存 factory / duplicator 再利用。

## Fallback / Mirror Handling
| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | 注意 | embed は意図的な複製（snapshot）。元 graph と新 node のリンクは持たない（独立 map）。reference 経路のみ共有 |
| legacy | なし | 既存の選択→resource auto-link を壊さない |

## State / Invariant
| invariant | 内容 |
|---|---|
| 単一文脈所有 | 文脈所有者は常に node 1つ（二重所有なし） |
| 手動層保持 | overwrite でも `document`/手動層は不変 |
| 既定非破壊 | default（新規）は既存 node を一切変更しない |

## baseline 整合
`GENERATION_GRAPH_MODEL.md` §10、`PRODUCT_DEFINITION.md` §5.1、`GRAPH-14`。
