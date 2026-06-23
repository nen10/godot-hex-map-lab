# REPAIR-10 Handoff issue matrix

日付: 2026-06-22
参照: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`

このmatrixは、handoffで残った不明点を見える状態に保つためのもの。repair-nowとfollow-upを分け、1つのviewport patchでBuild graph全体の混乱が解消したように扱わない。

## repair-now

| issue | handoff signal | 判断 | proof |
|---|---|---|---|
| Generate後にviewport表示されない | "結局viewportには表示できていない" | top Generate / Simple Generateのviewport projectionを修復する。 | viewport projection report + layer display cells |
| context race | Generateが`build_context_requested.emit()`の副作用に依存していた | 同期providerを追加し、run前に結果を検査する。 | `set_build_context_provider` tests |
| thumbnail混乱 | 四角tile panelがGenerate結果と誤認された | thumbnail/cacheをcompletion proofにしない。 | `node_thumbnail_secondary: true`; thumbnail-only proof拒否test |
| Result優先 | Result node追加後のproofが不明 | selected/terminal Resultを他outputより先にpromoteする。 | vertical slice Result test |
| reversible preview | Apply/Revert追加後のproofが不明 | projection前にdocument snapshotを取り、Apply/Revertでstateを明示的に変更する。 | Apply/Revert test |
| Apply failure | projection失敗でも成功UIに見える可能性 | projection成功規則を満たさない限りApplyをdisabledにする。 | projection failure state |
| canvas高さ/可読性 | graph高さ、button配置、node text clippingが指摘された | hotfix範囲でgraph高さとlabel可読性を修復する。文字は小さくしすぎない。 | screen snapshot / layout contract |
| node追加paletteの位置 | graph下部に置いてほしい対象が混乱した | batch / Apply / Revert / Removeではなく、`Add Node`と`Source`から`Result`までのnode button rowをgraph下部に置く。 | follow-up design |

## follow-up required

| follow-up id | issue | REPAIR-10に含めない理由 |
|---|---|---|
| `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT` | Resultは`1 terrain + N overlay`であるべき。各overlayは別layerとして保持する。 | Resource/runtime contract拡張が必要で、viewport repairを超える。 |
| `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES` | intermediate terrain/overlayはmain scene node dataに混ぜない。 | scene ownershipとrun-replace設計が必要。 |
| `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT` | 旧Generate state model、Region Filter item-key UX、Terrain Filter / Overlay Filter分離。 | node-state設計とinspector redesignが必要。 |
| `REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING` | `Add Node` + node button rowをgraph下部へ配置し、nodeをlayer生成段階ごとに整理する。`Source`の出力型を明示する。 | canvas layoutとSource typing設計が必要。 |
| `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE` | edge deletionがまだ壊れていると報告されている。 | interaction modelとGraphEdit event proofが別task。 |
| `REPAIR-15_MARKOV_ADJACENCY_MAPPING` | Markov Mesh / adjacency rulesが旧Generate意図と一致しているか不明。 | old-state parity auditと生成method mappingが必要。 |

## 完了証明として拒否するもの

| 拒否するもの | 理由 |
|---|---|
| thumbnail-only preview | output summary/cacheを示すだけで、viewport表示を示さない。 |
| sample-only success | sampleはonboarding assetであり、任意project proofではない。 |
| cache-only tests | graph cacheがあってもviewport projectionは失敗しうる。 |
| `display_used_cell_count()`単独 | tree attachment、tile source readiness、projection report成功を証明しない。 |
| 旧roadmap COMPLETE status | screenshotとhandoffにより、Build Generate viewport proofとしては信用しない。 |

## code上の不明点

| code area | 現在の不明点 | REPAIR-10での扱い |
|---|---|---|
| `HexTileMapLayer.ensure_display_tiles()` | editor timingによりdisplay layerが未readyになる可能性。 | projection reportに`display_tiles_ready`、tree state、tile status、used cellsを残す。 |
| `HexMapDocumentApplier.prepare_document_apply()` | generated terrainが既存empty/manual layerの後ろに隠れる可能性。 | preview用document copyではgenerated nonempty terrainを前に並べる。 |
| `HexGenerationPreset` | Simple GenerateがResultで終端していなかった。 | preset graphをResult終端にしてResultを選択する。 |
| `HexMapBuildGraphCanvas` slot type | Region Filterはterrain/overlayをacceptするが、GraphNode slot visual typeは1つ。valid connection type登録も不明。 | follow-upに記録。viewport修復では解決しない。 |
| `Source` node | 現状は「何でも入る」ように見える。Terrain Filter / Overlay Filter分離後に、接続先と出力型の整合が曖昧になる。 | `Source`をtyped sourceとしてUI上で明示する設計へ送る。 |
| `_run_region_filter` item-key mode | handoffではoverlay-only/dropdownが意図。現codeはterrain item keyも扱う。 | follow-up state/filter splitへ分離。 |
| `_run_wall_field` / `_run_item_generator` | Markov/adjacency mappingが旧Generateを誤解している可能性。 | follow-up parity taskへ分離。 |
| edge deletion | Remove buttonはnode削除寄り。edge deletionは報告上まだ不十分。 | follow-up interaction taskへ分離。 |
