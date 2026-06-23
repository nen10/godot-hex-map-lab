# REPAIR-10 visual probe plan

## 目的

testに頼る前に、Build Generateが実際にviewport layerへ投影したかを診断する。これはdiagnostic proofであり、analog testではない。

## probe contract

probeは以下を記録する。

- 選択layer名/path
- layerがscene tree内にあるか
- Build contextがdocument/graph/layerを作成したか
- Generate run result
- viewport projection report
- display used cell count
- display tile status
- screenshot capture可能なruntimeではcapture status
- screenshot capture可能なruntimeでは非背景pixel sample数

出力先:

`./.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/`

## failure interpretation

- graph cacheが存在してもprojection reportが失敗なら、修復未完了。
- `display_used_cell_count() == 0`なら、修復未完了。
- layer pathが空、またはtree内にないなら、修復未完了。
- thumbnail/cache dataだけなら、修復未完了。

## expected proof files

- `build_generate_viewport_probe.json`
- runtimeがscreenshot capture可能な場合のみ`build_generate_viewport_probe.png`
