# REPAIR-10 Build Generate viewport表示とgraph混乱回復 Sub Tasks

日付: 2026-06-22
Complexity: C5
Queue: `IMPLEMENTATION_QUEUE.md`
参照handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`

## task境界

このtaskは、Buildの`Generate`を押したときのfirst impressionを修復し、handoffで発生した混乱を明示的な設計負債として記録する。

Build tab全体の再設計ではない。また、このtaskだけでgraph製品全体が完成したとは扱わない。

## repair-now

- [x] REPAIR-10 task packetとqueue entryを作成する。
- [x] top `Generate` / `Generate (Simple)`が、実行前に同期的にBuild contextを取得する。
- [x] 選択中の`HexTileMapLayer`を対象にし、なければ`BuildHexMapLayer`を作成して選択する。
- [x] graph実行前に`Level Document`とembedded graph resourceを作成/付与する。
- [x] Generate後のprojection順序を固定する。
  - 選択中outputが`result`なら最優先。
  - terminal `result`があれば次に使う。
  - graph resourceのpromote targetがあれば使う。
  - terminal terrain/overlay outputを使う。
  - 最後に選択中outputの型からpromote roleを決める。
- [x] `ensure_display_tiles()`を呼び、document由来のmapをactive layerへapplyする。
- [x] viewport preview成功は、projection report、tree attachment、display tile準備、display cell存在をすべて満たした場合だけにする。
- [x] 生成previewは`Apply` / `Revert`で可逆にする。
- [x] viewport projectionが失敗した場合は`Apply`できないようにする。
- [x] `HexMapPreviewThumbnail`はsnapshot/cache補助としてのみ扱い、visible Build resultとは扱わない。
- [x] Build canvasのrepair-now範囲のlayoutを修正する。
  - canvasを主要な高さにする。
  - batch / Apply / Revert / Removeをgraph下部へ移す。これは達成済み。
  - node/button textは可読性を優先する。読み取り不能な縮小は禁止。
  - normal stateでnode label / port labelが切れないようにする。
- [x] viewport projection JSONを書き出すdiagnostic probeを追加する。
- [x] targeted testsでthumbnail/cache-only successを拒否する。

## このtaskで予定したfollow-up

以下はhotfixでは解決しない。viewport修復に混ぜず、次taskとして残す。

- `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT`: Resultは`1 terrain + N overlay`を持つ。各overlayは別のgenerated overlay layerとして保存する。
- `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES`: intermediate terrain/overlay outputはmain scene node dataに混ぜず、runごとに置換されるchild nodeにする。
- `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT`: graph-wide generation state、旧Generate意図のmapping、Region FilterをTerrain Filter / Overlay Filterへ分離する設計。
- `REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING`: graph下部に`Add Node` + node button rowを配置し、node buttonをlayer生成段階別に整理する。`Source`は今後のTerrain/Overlay Filter分離に追随できるよう、出力型をUI上で明示する。
- `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE`: edge deletion操作とgraph canvas interactionの修復。
- `REPAIR-15_MARKOV_ADJACENCY_MAPPING`: Markov Meshとadjacency rulesを旧Generate state遷移と照合する。

## completion gate

完了には以下が必要。

- `docs/plan/.../REPAIR-10.../HANDOFF_ISSUE_MATRIX.md`
- viewport projection probe JSON
- targeted tests:
  - `tests/test_generation_promote.gd`
  - `tests/test_build_screen_full.gd`
  - `tests/test_build_graph_canvas.gd`
- final gate: `./tools/test.sh`

完了証明として拒否するもの:

- thumbnailだけのpreview
- sampleだけの成功
- graph cacheだけを証明するtest
- target layer pathとviewport projection reportを持たないscreen snapshot
