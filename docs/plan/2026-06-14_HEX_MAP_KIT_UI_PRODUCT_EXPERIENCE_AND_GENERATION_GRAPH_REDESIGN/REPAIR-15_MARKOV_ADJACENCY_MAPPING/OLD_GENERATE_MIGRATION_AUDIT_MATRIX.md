# Old Generate tab -> Build graph migration audit matrix

日付: 2026-06-24
状態: audit record (code-grounded)
目的: 旧 Generate tab (`addons/hex_map_kit/editor/hex_map_gen_dock.gd`, 5961 行) が持っていた state / behavior が、Build graph (node / derived state / UI) にどこまで移行されたかを一望し、`migrated / partial / dropped` を分類する。個別 hotfix を積む前に、移行漏れを一次資料として固定する。

## 凡例

- `migrated`: Build graph 側で同等の意味が実装され、editor から到達できる。
- `partial`: engine か UI の片方しか無い、または意味が縮退している。
- `dropped`: Build graph に対応が無い（意図的廃止 or 未移行）。
- `verify`: コード上の存在は確認したが、editor 実挙動の最終確認が必要。

## 旧 dock の主要 state 源（コード根拠）

| old surface | 代表シンボル(gen_dock) |
|---|---|
| generator/target/shape/size/seed/run mode | section `generate_configuration` |
| simple shape | `_shape_option_simple` |
| symmetric shape | `_shape_option_symmetric`, `generate_symmetric_*` |
| seed + seed lab(batch+score) | `_seed_spin`, `_seed_lab_*`, `_seed_lab_score_tree` |
| wall method | random / markov_mesh |
| markov distribution preset | `distribution_id` |
| markov custom distribution | `_current_distribution` |
| protected floor | `protected_floor` |
| connectivity method | `_connect_method_option` |
| toric passage | `_torus_connectivity_check` |
| overlay mode | `_overlay_mode_check` |
| item name / limit / pool | `_overlay_item_name_edit`, `_overlay_item_limit_*`, `_overlay_item_pool_*` |
| adjacency rules | `HexAdjacencyRuleEditor`(text LineEdit) |
| overlay mask query + crop | `_overlay_mask_query_*`, `_overlay_mask_crop_check` |
| deductor floor query | `_overlay_deductor_floor_*` |
| source registry / overlay source stack | `_source_registry_*`, `_mapdata_sources` |
| output target preview/apply/save | section `generate_output` |
| profile source | section `profile_source` |

## 移行マトリクス

| # | old behavior/state | Build graph 対応 (node / state / UI) | status | 備考 / follow-up |
|---|---|---|---|---|
| 1 | simple shape (rect/square/hex) + size + toric | `Shape` node params (`shape/width/height/size/radius/toric`) | migrated | REPAIR-13 で param flush 済み。 |
| 2 | symmetric shape 生成 | Build `Shape` には symmetric 選択肢が無い | dropped | symmetric 地形生成意図を node option として復活させるか要判断。 |
| 3 | base seed | graph-wide `graph_settings.seed` + node salt | migrated | REPAIR-13 で確定。 |
| 4 | seed lab (batch run + score tree + promote) | Build は batch count + seed randomize のみ。score/lab 無し | partial | scoring/seed-lab UI は未移行。価値判断が要る（自動探索UX）。 |
| 5 | wall: random probability | `Wall Field` random_probability | migrated | |
| 6 | wall: markov mesh + distribution_id preset | `Wall Field` markov + `distribution_id` | migrated | |
| 7 | wall: custom distribution (`_current_distribution`) | `Wall Field` `custom_distribution` + Markov window (REPAIR-18) | partial | REPAIR-18 は 8-weight 配列で再導入。旧 `_current_distribution` object の意味(サイズ可変 prob)との parity 確認が要る (verify)。 |
| 8 | protected floor | core は `protected_floor` を受けるが Build inspector に UI 無し | partial | Wall/Connectivity の protected floor 入力 UX が未移行。 |
| 9 | connectivity method (dense/sparse/terminal/none) | `Connectivity` `method` | migrated | |
| 10 | toric passage (`_torus_connectivity_check`) | Build connectivity に toric option 無し | partial | toric connectivity を node param 化するか要判断。 |
| 11 | overlay mode (terrain vs overlay 出力切替) | typed `Source Overlay` / `Item Generator`(overlay 出力) / Result overlay | migrated | REPAIR-11/13A/16 で型として整理。 |
| 12 | item name / item pool (weighted) | `Item Generator` weighted + item_pool(weight) | migrated | |
| 13 | item limit (count) | `Item Generator` limited は core `remaining` を読むが inspector は weight しか書かない | partial | findings #1。limited の個数フィールド UI が未配線（design-system 込みで要設計）。 |
| 14 | adjacency rules (旧 text editor, 欠陥) | `Item Generator` adjacency_rules + 構造化 Adjacency Rules window (REPAIR-17) | partial→改善 | 旧も text で欠陥。REPAIR-17 で structured 化。ただし direction toggle は state 保持のみで、core は count/components のみ使用。direction を生成 semantics に効かせるか要判断。 |
| 15 | include_generated_reference | `Item Generator` param 有り。但し線形走査で偏る | partial | findings #2。対称走査 core への接続 + test が未了。 |
| 16 | overlay mask query + crop | Terrain/Overlay Filter + Set Operation で部分代替可だが mask/crop 専用意味は未移行 | partial | mask(参照集合での絞り込み)と crop の意味を filter/operator にどうマップするか要設計。 |
| 17 | deductor floor query | 同上、専用 query は未移行 | dropped (verify) | 旧 deductor floor の生成意図を node として要再定義。 |
| 18 | source registry / overlay source stack | typed `Source` nodes + resource refs | partial | 複数 source の stack/registry 管理 UX は縮退。 |
| 19 | output: preview only / apply to document / save tres | Build `Generate`(preview) / `Apply` / `Revert` + graph resource | migrated | モデルは別(preview-pending)。REPAIR-10 で確立。 |
| 20 | profile source | Build `Generate (Simple)` profile | migrated | |

## 優先度付き gap（個別 task への分岐）

| 優先 | gap (#) | 推奨 routing |
|---|---|---|
| P0 | #13 limited count UI/配線 | 小さく確実。Item Generator inspector の method別 item row 再設計（design-system）。 |
| P0 | #15 adjacency 対称走査 + test | core 接続 + bias 回帰 test。 |
| P1 | #8 protected floor UI | Wall/Connectivity inspector へ protected floor 入力。 |
| P1 | #14 adjacency direction semantics | direction mask を core が使うか(=core 拡張) UIだけかの判断。 |
| P1 | #7 markov custom parity | 旧 `_current_distribution` と REPAIR-18 8-weight の意味差確認。 |
| P2 | #2 symmetric shape / #10 toric passage | node option 復活の要否判断。 |
| P2 | #16 mask+crop / #17 deductor floor | filter/operator へのマップ設計、または専用 node。 |
| P2 | #4 seed lab / #18 source registry | 高度UX。移行価値の判断（drop も選択肢）。 |

## REPAIR-17/18 への含意（このauditで明確化）

- 旧 `HexAdjacencyRuleEditor` は構造化ではなく **text LineEdit**（`default=0.2;1=0.8;2,1=0.4`）であり、ユーザー指摘どおり欠陥設計。REPAIR-17 の structured window は方向性として正しい改善。残課題は direction toggle の semantics（#14）。
- 旧 markov custom distribution は `_current_distribution` という object（サイズ可変 `prob`）。REPAIR-18 は 8-weight 固定配列で再導入。3 reference 前提で 8-state なら一致するが、参照数が異なる場合の parity は要確認（#7, verify）。

## 次アクション

1. P0（#13, #15）を REPAIR-15 配下の実装 slice として切り出す。
2. P1（#8, #14, #7）は判断事項を本 matrix で確定してから実装。
3. P2 は「移行 or drop」をユーザー判断で確定し、drop は明示記録する（無音 drop しない）。
