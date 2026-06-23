# REPAIR-10 UX

## user story

ユーザーがBuildで`Generate`を押すと、生成mapが実際の`HexTileMapLayer`としてGodot 2D viewportに表示される。ユーザーは`Apply`で保持し、`Revert`で生成前のin-memory documentへ戻せる。

## first impression

最初に証明するべきものはviewportであり、四角いnode-output panelではない。viewportへ投影できなかった場合、UIは成功したように見せてはいけない。

期待する見え方:

1. ユーザーがBuildを開く。
2. ユーザーが`Generate`を押す。
3. `HexTileMapLayer`が選択されていれば、そのlayerを使う。
4. 選択layerがなければ`BuildHexMapLayer`を作成して選択する。
5. 生成されたterrain/overlayがGodot viewportに表示される。
6. viewport projectionが成功した場合だけ`Apply` / `Revert`が有効になる。

## secondary preview

`HexMapPreviewThumbnail`はnode outputの概要、またはcache補助である。Buildのcompletion surfaceではない。testも、これをviewport表示の証明として扱ってはいけない。

## layout repair

このtaskで扱うlayout修復は、Build操作の明瞭性を妨げる範囲に限る。

- graph canvasは主要な作業面として十分な高さを持つ。
- batch / Apply / Revert / Removeをgraph下部のaction rowへ置く修正は達成済みとして扱う。
- 次にgraph下部へ置くべき対象は、node追加UIである。具体的には`Add Node`と`Source`、`Shape`、`Wall Field`、`Connectivity`、`Terrain Filter`、`Overlay Filter`、`Set Operation`、`Item Generator`、`Compose`、`Result`のbutton列。
- node label / port labelは通常状態で読める。
- 文字サイズは読みやすさを優先する。Godot editor上の作業画面であり、モバイル用の12px級縮小を前提にしない。
- button文字はdock幅に収めるが、視認不能な縮小はしない。

## node追加rowの整理

node追加UIは、単なるnode一覧ではなく「各nodeがどのlayer生成段階に関わるか」で行を整理する。

| group | node button | 位置付け |
|---|---|---|
| 入力 / 参照 | `Source` | 既存document、map resource、overlay resource、result resourceなどをgraphへ取り込む境界。 |
| terrain生成 | `Shape`, `Wall Field`, `Connectivity` | terrain layer候補を生成・補正する。 |
| selection / filter | `Terrain Filter`, `Overlay Filter`, `Set Operation` | terrainまたはoverlayからselectionを作る。旧`Region Filter`はここで再整理する。 |
| overlay / item生成 | `Item Generator`, `Compose` | selectionからoverlay/item layer候補を作る。 |
| 出力 / viewport反映 | `Result` | 最終的にviewportへ投影するterrain + overlayを集約する。 |

現状の`Source`は「何でも入る」nodeに見えるため、今後の`Terrain Filter` / `Overlay Filter`分離と衝突しやすい。次の設計では、`Source`が出す型をUI上で明確にし、terrain sourceは`Terrain Filter`へ、overlay sourceは`Overlay Filter`へ自然に接続できるようにする。

未決事項:

- `Source`を1つのnodeのままにし、`output_type` chip / modeで`terrain` / `overlay` / `result`を明示するか。
- node追加buttonを`Source Terrain` / `Source Overlay`のように分け、内部node typeは同じ`Source`にするか。
- `Result` sourceを許可する場合、`Result Terrain Source` / `Result Overlay Source`へ分解して扱うか。

## failure state

生成dataが存在してもviewport projectionが失敗した場合:

- `Apply`はdisabledのまま。
- valid pending previewがなければ`Revert`もdisabledのまま。
- status textはprojection失敗理由を示す。
- snapshotはprojection failure reportを持つ。
