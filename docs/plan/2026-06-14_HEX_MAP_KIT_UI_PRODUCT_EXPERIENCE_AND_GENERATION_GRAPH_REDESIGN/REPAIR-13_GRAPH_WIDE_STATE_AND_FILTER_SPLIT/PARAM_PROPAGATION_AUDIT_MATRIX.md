# Build Graph 設定伝達監査マトリクス

## 目的

Generate 後に viewport が変わらない、または `Shape` に値を設定しても生成結果に反映されない問題は、単一のボタン不具合として扱わない。

この文書では、Build graph の全設定項目がどこで失われる可能性があるかを、UI から viewport 表示まで一列に並べて監査する。実装修正の前に、ここで未確認箇所を明示する。

## 前提

- この文書は設計・監査文書であり、実装完了証明ではない。
- 「サンプルだけ動く」は完了証明ではない。
- 「ノード出力の小さなサムネイルが変わる」は viewport 表示の完了証明ではない。
- Generate の完了証明は、active layer の document と viewport display cell が変化することで確認する。
- `Generate -> Apply -> Generate` で初めて viewport に表示される挙動は、状態遷移または projection 経路の欠陥として扱う。

## 伝達経路

各設定項目は次の経路を通る必要がある。

1. UI control
2. 選択ノードの parameter state
3. Graph node metadata / graph model
4. graph resource の保存・再読込
5. generation runner の node 実行
6. output cache
7. Result / promote 対象
8. document projection
9. active layer の `apply_map()`
10. viewport display

どこか 1 箇所でも欠けると、UI 上は設定したように見えても Generate 結果には反映されない。

## 監査カラム

実装前に、各項目を次の形式で確認する。

| カラム | 意味 |
|---|---|
| Node | 対象ノード |
| Parameter | UI 上の設定項目 |
| UI Control | 入力 UI の種類 |
| Graph Key | graph model / resource に保存される key |
| Runner Read Key | runner が読む key |
| Output Effect | 出力に期待される変化 |
| Viewport Proof | viewport 上の確認方法 |
| Status | 未確認 / 欠落 / 実装済み / テスト済み |

## P0 監査対象

最初に確認する対象。

| 対象 | 理由 |
|---|---|
| `Shape` の形状・サイズ値 | ユーザー確認で Generate に反映されていない |
| `Generate -> Apply -> Generate` | Apply 後だけ表示される状態依存がある |
| `Source` の出力型 | Region Filter 改善と型設計が衝突している |
| `Region Filter` | terrain filter と overlay filter の分離が必要 |
| Result projection | ノード出力ではなく viewport に表示されるかの核になる |

## Source

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| source kind | source の由来を示す | sample 固定に落ちていないか |
| output type | terrain / overlay / result / document を明示 | downstream validation が読めるか |
| resource ref | 外部 Resource 参照 | raw path text 依存になっていないか |
| active layer ref | workspace の selected layer | Generate 時に同期されるか |
| document ref | Level Document | graphless layer に付与されるか |
| embedded graph ref | Layer 内 graph | Generate 前に存在するか |

未解決:

- UI 上は `Source Terrain` / `Source Overlay` に分ける。
- 内部 model は typed Source node + `output_type` を第一候補にする。
- `Source` が「何でも入る」設計のままだと、filter split 後の validation が不明瞭になる。

## Shape

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| shape | rectangle / hex / custom など | runner が UI 値を読んでいるか |
| width | 横方向サイズ | default 値に戻っていないか |
| height | 縦方向サイズ | graph model に保存されるか |
| radius | hex / circular 系のサイズ | shape 種別ごとに有効・無効が整理されているか |
| orientation | flat / pointy | Result / layer display と矛盾しないか |
| seed | deterministic generation | Run State の seed と混ざっていないか |

現在の疑い:

- UI の `Shape` 値が graph model または runner に伝わっていない。
- Generate 直後の projection が古い cache / old document を見ている可能性がある。

## Wall Field

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| mode | wall 生成方式 | runner key と一致するか |
| probability | wall 発生率 | 0 / 1 / default の扱い |
| seed | wall 固有 seed | batch seed との合成規則 |
| protected floor | 床領域保護 | terrain input と整合するか |
| distribution | 分布設定 | UI だけの値になっていないか |

## Connectivity

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| mode | 接続補正方式 | runner が読む key |
| terminals | 接続対象端点 | input から算出か UI 指定か |
| seed | 補正 seed | graph run seed と混ざらないか |
| preserve regions | 既存領域の保持 | output に差が出るか |

## Terrain Filter

`Region Filter` から分離する予定の terrain 専用 filter。

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| input terrain | terrain output のみ受ける | overlay input を invalid にできるか |
| filter target | terrain kind / region / coordinate | 値候補が input から出るか |
| distance origin | 距離基準 | coordinate / selection / terminal の扱い |
| max distance | 距離閾値 | output selection に反映されるか |
| shift q/r/s | hex 座標 shift | coordinate system と一致するか |
| invert | selection 反転 | downstream set operation と矛盾しないか |

## Overlay Filter

`Region Filter` から分離する予定の overlay 専用 filter。

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| input overlay | overlay output のみ受ける | terrain input を invalid にできるか |
| item key | upstream overlay の item key 候補から選ぶ | raw text ではなく候補表示にできるか |
| match mode | exact / category / tag など | data model に存在するか |
| distance origin | item / coordinate / selection | terrain filter と混同しないか |
| max distance | 距離閾値 | item 周辺 selection に反映されるか |
| shift q/r/s | hex 座標 shift | overlay cell と terrain cell の対応 |
| invert | selection 反転 | empty selection の扱い |

未解決:

- `item key` 候補を実行済み output cache から出すのか、upstream Item Generator の計画 state から出すのか。
- 未実行 graph でも item key 候補を出す必要がある場合、Derived Graph State に planned overlay key を持たせる必要がある。

## Set Operation

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| operation | union / intersect / subtract など | input selection 型の検証 |
| input order | A/B の意味 | subtract で順序が失われないか |
| empty behavior | 空 selection の扱い | validation と preview が一致するか |

## Item Generator

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| scope | selection / terrain など | input 型と一致するか |
| placement mode | 配置方式 | runner key と一致するか |
| probability | 配置確率 | UI 値が output overlay に出るか |
| seed | item 配置 seed | batch seed との合成 |
| item pool | 配置候補 | Overlay Filter の item key 候補とつながるか |
| item key / name | 生成 item の識別 | display / filter / document に残るか |
| blocked rule | 配置不可条件 | terrain / overlay と整合するか |

## Compose

`Compose` は初期 primary node add row から外す。

final composition は `Result` が担当するため、ここでは実装監査対象ではなく、将来の advanced node 候補として扱う。

## Result

| Parameter | 期待する扱い | 監査ポイント |
|---|---|---|
| terrain input | viewport terrain の主入力 | selected output より優先されるか |
| overlay input | viewport overlay の主入力 | terrain と同時 projection されるか |
| object input | object document state | snapshot / revert に含むか |
| orientation | layer 表示方位 | Shape / layer orientation と矛盾しないか |
| overlay inputs | 複数overlay入力 | `overlay_inputs[]` として全て認識されるか |
| result output | terminal result | downstream input ではなく preview / projection 対象として扱うか |

## Viewport Proof

Generate の成功は次の snapshot で確認する。

| Snapshot key | 期待値 |
|---|---|
| viewport_preview_visible | `true` |
| viewport_preview_layer_path | active layer の path |
| viewport_preview_cell_count | `> 0` |
| preview_commit_state | `preview_pending` / `applied` |
| node_thumbnail_secondary | `true` |

サムネイルだけが変わる状態は、viewport proof として受け入れない。

## 打ち合わせが必要な不明点

1. `Shape` のサイズ設定は、どのノード出力に対して最終的に visible cell count の差として証明するか。
2. Source は UI 上で `Source Terrain` / `Source Overlay` に分け、内部 model を typed Source にする前提でよいか。
3. Overlay Filter の item key 候補は、未実行 graph でも表示する必要があるか。
4. `Result` node が無い graph で terminal output を Promote する時、terrain と overlay の両方をどう確定するか。
5. Apply 後の Generate が初回 Generate と違う結果になる場合、Apply がどの state を暗黙に初期化しているか。
6. Preview snapshot の対象は terrain / overlay / object document state で足りるか。
7. Revert 後に graph output cache を残すか、invalid にするか。
