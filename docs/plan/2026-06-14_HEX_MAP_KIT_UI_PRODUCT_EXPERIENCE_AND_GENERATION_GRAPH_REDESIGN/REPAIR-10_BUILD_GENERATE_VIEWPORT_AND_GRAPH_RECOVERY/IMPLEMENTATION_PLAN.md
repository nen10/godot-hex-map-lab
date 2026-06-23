# REPAIR-10 実装計画

## scope

Buildの`Generate`経路を修復し、実際のviewport layerへ投影されることを証明する。handoffで残った不明点はfollow-up taskとして明示し、この修復で全解決した扱いにしない。

## 手順

1. 文書とqueue
   - このtask packetを追加する。
   - `REPAIR-10`をrepair taskとしてqueueに追加する。
   - handoff issue matrixからfollow-up taskを追加する。

2. context契約
   - `HexMapBuildScreen.set_build_context_provider(provider: Callable)`を使う。
   - top `Generate` / `Generate (Simple)`は、graph実行前にproviderを呼ぶ。
   - providerは対象layer、document、graph、restore statusを返す。
   - 互換性のため`build_context_requested` signalは残してよい。ただし`Generate`成功は、画面側が検査できないsignal副作用に依存してはいけない。

3. viewport projection
   - projection前にdocument snapshotを取る。
   - 選択中またはterminalの`Result`を、他outputより先にpromoteする。
   - display tilesを保証したactive layerへdocument snapshot由来のmapをapplyする。
   - layer path、tree state、display tile状態、used cells、blocked reasonを含むviewport projection reportを記録する。

4. preview commit state
   - `none`: pending/kept previewなし。
   - `preview_pending`: viewport projection成功。`Apply` / `Revert`が可能。
   - `applied`: ユーザーがpreviewを保持。`Revert` disabled。
   - `reverted`: ユーザーが生成前documentとdisplayへ戻した。

5. Simple Generate
   - Simple preset graphは`Result`で終端する。
   - Simple Generateもtop Generateと同じcontext取得とviewport proofを使う。

6. Build canvas整理
   - batch / Apply / Revert / Removeをgraph下部へ移す。この修正はREPAIR-10時点で達成済み。
   - canvasのminimum heightを増やし、dock内で主要な作業面にする。
   - node label / port labelは通常状態で読めるようにする。
   - 文字サイズは小さくして収めるのではなく、可読性を優先する。

7. 次のBuild canvas整理として残すもの
   - graph下部へ移すべき未完了対象は、batch / Apply / Revert / Removeではなくnode追加UI。
   - `Add Node`と各node buttonをgraph下部に置く。
   - node buttonはlayer生成段階でgroup化する。
   - `Source`は出力型を明示し、将来の`Terrain Filter` / `Overlay Filter`分離と矛盾しない形にする。

8. diagnostic probe
   - Build Generate viewport probe scriptを追加する。
   - `.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/`へJSONを書き出す。
   - runtimeがcapture可能な場合だけscreenshotと非背景pixel samplingも記録する。

9. tests
   - `tests/test_generation_promote.gd`を更新する。
   - `tests/test_build_screen_full.gd`を更新する。
   - 必要に応じて`tests/test_build_graph_canvas.gd`でlayout/snapshot contractを固定する。
   - targeted testsを先に実行し、その後`./tools/test.sh`を実行する。

## acceptance

- 選択layerなし: top Generateが`BuildHexMapLayer`を作成/選択し、document/graphを付与し、成功したviewport projectionを記録する。
- graphなしの選択layer: top Generateが同じlayerを維持し、document/graphを付与し、成功したviewport projectionを記録する。
- Resultを持つvertical slice: GenerateがResult経由でterrainとoverlayをpromoteし、active layerへapplyする。
- Revertは生成前document stateとviewport displayを復元する。
- Applyは生成viewport resultを保持し、Revertをdisabledにする。
- 四角thumbnail/cacheだけの証明は明示的に拒否する。
