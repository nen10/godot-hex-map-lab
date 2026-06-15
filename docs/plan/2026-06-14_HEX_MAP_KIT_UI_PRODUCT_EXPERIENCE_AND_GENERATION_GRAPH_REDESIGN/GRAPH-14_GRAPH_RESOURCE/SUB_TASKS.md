# GRAPH-14 SUB_TASKS

Complexity class: **C2**（Dictionary model の Resource 化。serialize/round-trip。機械的。）

## Task Resolution
`GRAPH-12` で slice が安定した後、graph を `HexGenerationGraphResource`(Node/Port/Edge) として永続化できるようにする。MVP の Dictionary model と相互変換（公開 API 前提）。`RUNTIME-50/51`（runtime build / load）が依存。

## 確定設計
| 論点 | 決定 |
|---|---|
| 表現 | `HexGenerationGraphResource`（@export: nodes/edges、+ embed semantics snapshot 用フィールド） |
| 変換 | `to_dict()` / `from_dict()` で `GRAPH-10` Dictionary model と相互変換 |
| embed | semantics snapshot を任意 embed（`RUNTIME-50/51` 自己完結用） |

## Scope
含む: Resource class、Dictionary 相互変換、save/load round-trip、embed フィールド。
含まない: editor 読込 UX（RUNTIME-51）、runtime build（RUNTIME-50）。

## Scheduled Task Audit: なし。
## Sub-tasks
1. `HexGenerationGraphResource`（node/edge/embed フィールド）。
2. `to_dict()`/`from_dict()`。
3. save/load round-trip test。
fallback/mirror: なし。
