# GRAPH-10 POLICY

## 採用方針

- **生成 engine 非新規**: node の run は core static（`hex_map_generator.gd` / `hex_map_data.gd` / `hex_overlay_data.gd`）を呼ぶ。アルゴリズムを再実装しない。
- **headless / UI 非依存**: `addons/hex_map_kit/generation/` は editor を参照しない。
- **Resource 非破壊**: Source は既存 Resource を読み取り、必要なら複製してから graph に取り込む。

## Fallback / Mirror Handling

| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | 新規 subsystem。fallback を導入しない。 |
| mirror flag | なし | 状態の二重持ちを作らない。 |
| legacy 互換 | なし | 既存 gen_dock の生成 path を変更しない（並存。retire は後続）。 |

## State / Invariant Table

| invariant | 内容 |
|---|---|
| DAG | graph は有向非巡回。cycle は `validate` で error。 |
| 型整合 | edge は `out_type ∈ to_port.accepts`。違反は error。 |
| 必須入力 | node の必須入力ポートが全て接続済み（または default）でなければ error。 |
| 決定性 | 同一 graph + 同一 seed/context → 同一 output。 |
| 非破壊 | run は入力 Resource / 上流 cache を破壊変更しない（各 node は新 output を返す）。 |
| 純粋 pass | node.run は副作用を持たない（Document 書き込み等は GRAPH-10 scope 外）。 |

## Port 型ルール

| port 型 | 実型 | 生成元 node |
|---|---|---|
| `terrain` | `HexMapData` | source / shape / wall_field / connectivity |
| `selection` | `Array[HexPoint]`（cell 集合） | region_filter |
| `overlay` | `HexOverlayData` | source / item_generator / compose |
| `result` | `HexGenerationResultResource` | （GRAPH-10 では未使用。後続 promote/preview 用に定数のみ定義） |

多型入力（例 `region_filter.in` が `terrain|overlay` を許容）は accepts に型集合を持つ。

## baseline 整合

`docs/design/GENERATION_GRAPH_MODEL.md`（§1 headless pass / §2 port / §3 node / §9 reuse）、`docs/design/PRODUCT_DEFINITION.md` §3 に準拠。
