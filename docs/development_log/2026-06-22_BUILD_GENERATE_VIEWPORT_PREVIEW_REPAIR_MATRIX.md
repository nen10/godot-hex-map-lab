# Build Generate viewport表示 修復matrix

日付: 2026-06-22
参照handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
roadmap baseline: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ROADMAP.md`

## 決定

`Generate`は、生成結果を実際の`HexTileMapLayer`経由でGodot 2D viewportへ投影する。

選択中の`HexTileMapLayer`があればそこを対象にする。なければBuild側で`BuildHexMapLayer`を作成して選択する。

生成結果は`Apply`までpending preview。`Revert`は生成前のin-memory documentを復元し、対象layerへ再適用する。

四角tile panelに見えるものは`HexMapPreviewThumbnail`系の出力概要であり、Buildの主結果ではない。snapshot上にthumbnail情報が残っても、それはviewport projectionの完了証明ではない。

## matrix

| 項目 | 判断 | 理由 | 証明方法 |
|---|---|---|---|
| Generate viewport経路 | repair-now | 主操作はnode cacheではなくviewportにmapを見せる必要がある。 | `tests/test_generation_promote.gd`のtop Generate viewport test |
| context provider race | repair-now | Build画面が実行前に対象layer/documentを同期的に把握できる必要がある。 | `HexMapBuildScreen.set_build_context_provider()` |
| preview thumbnailの扱い | repair-now | thumbnailがGenerate結果と誤認された。Build完了証明には使わない。 | 設計文書 + viewport proof fields |
| top Generate test | repair-now | 既存testはbootstrap/promote中心で、top buttonのviewport結果を証明していなかった。 | `tests/test_generation_promote.gd` |
| graph-wide generation state model | follow-up | node間のmode制約は重要だがviewport修復より大きい。 | 次のstate設計task |
| Region Filter item-key UX | follow-up | item-keyはraw textではなく、入力overlayで計画されるkeyから選ぶべき。 | 次のinspector/input-state task |
| graph canvas操作性/layout | follow-up | 高さ、node text clipping、edge deletionは独立したcanvas設計が必要。 | 次のBuild canvas UX task |
| node追加rowの位置 | follow-up | graph下部へ置く対象はbatch / Apply / Revert / Removeではなく、`Add Node`とnode button群。 | 次のBuild node add row task |
| Source typing | follow-up | `Source`が何でも入るnodeに見えると、Terrain Filter / Overlay Filter分離と衝突する。 | Source出力型を明示する設計task |
| edge deletion behavior | follow-up | 現在のRemove/Deleteではedge削除の実態証明が不足している。 | 次のgraph canvas interaction task |
| thumbnail-only preview proof | reject | thumbnailはcache/data概要であり、viewport表示を証明しない。 | `viewport_preview_visible`とprojection reportを必須化 |
| sample-only success | reject | sampleは学習素材であり、任意project assetのfeature完了ではない。 | selected/new project layerで証明 |
| cache-only graph test | reject | graph run/cache成功だけでは、user-visible projectionを証明しない。 | `viewport_apply_report.projection_ok`を必須化 |
