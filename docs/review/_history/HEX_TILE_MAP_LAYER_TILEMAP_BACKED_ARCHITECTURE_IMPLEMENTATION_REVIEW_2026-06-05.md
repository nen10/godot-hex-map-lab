# HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_REVIEW_2026-06-05.md

## 対象

- Completed UX: `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_UX_2026-06-03.md`
- Completed Policy: `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_POLICY_2026-06-03.md`
- Completed Implementation Plan: `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_IMPLEMENTATION_PLAN_2026-06-03.md`
- Completed Plan Review: `docs/complete_on_test/HEX_TILE_MAP_LAYER_TILEMAP_BACKED_ARCHITECTURE_PLAN_REVIEW_2026-06-03.md`

## Findings

### [P2] editor analogでの体感確認が未完了

headless testでは、`HexTileMapLayer` targetのmanual edit / Undo / Redoが `apply_document_cell()` と全量 `_redraw()` に戻らないことを確認できている。これは計画の中心要件を満たしている。

一方、計画の完了条件には「大きめmapでも1click後に表示が固まらず、選択cellだけ変化したように見えること」が含まれる。今回の差分には、Godot editor上でのanalog確認結果、または大きめmapでの操作時間比較が見当たらない。次計画へ残すなら、`tests/analog_test/` に「961 cell程度のmanual wall/floor/tile editで全画面blinkがない」「Last Edit / target statusが更新される」「Undo / Redoで同じcellだけ戻る」を記録するのがよい。

### [P3] document更新とtarget applyの順序は堅牢性を上げられる

`HexMapEditTool._apply_hex_tile_map_layer_edit_command()` は `_apply_hex_cell_state_to_document()` の後に `HexTileMapLayer.apply_edit_command()` を呼んでいる。通常のcommandは有効なので実害は出にくいが、target applyがfalseを返すケースではdocumentだけが先に進む余地がある。

自明な改善は、target apply成功後にdocumentへ反映する、またはtarget apply失敗時にdocument更新をskip / rollbackすること。UI上は「表示は変わらないのにSave対象だけ変わる」事故を避けられる。

該当: `addons/hex_map_kit/editor/hex_map_edit_tool.gd:954`

### [P3] Generator Primaryはstate API経由だが、API境界の見え方は揃えられる

Generator Primary applyは `HexTileMapLayer` へ接続済みで、setter経由で内部stateと表示を更新している。実装としては成立しており、testも通っている。

ただし計画上は `load_map_data()` / `load_map_resource()` で適用する記述だったため、将来のcode readingでは `layer.hex_map = ...` が旧Resource主導経路に見えやすい。実装意図を明確にするなら、Generator Dock側を `layer.load_map_resource(HexMapResource.from_map_data(...))` に寄せるか、`hex_map` setterがload APIの互換入口であることを短くコメントする。

該当: `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2166`

#### ユーザー意見

禍根を残さないよう、誤解の余地を排除したコードに仕上げましょう。

## 当初要件より優れている実装

- Manual Editの通常経路は、document全体を複製してResource変換し直す方式から、`cell_edit_state()` / `apply_edit_command()` / `inverse_edit_command()` によるcell command方式へ移っている。
- command stateはwall / floorだけでなく、floor tile override、overlay tile、object marker、label markerまで扱う。短期の描画改善に留まらず、今後のpayload編集を同じ状態境界へ集約しやすい。
- Save / Export前に `HexTileMapLayer.to_document_resource()` でtarget内部stateをsnapshot化するため、document未ロードのtarget由来編集でも保存経路が閉じている。
- Generator Primary applyが `HexTileMapLayer` に接続され、display TileSet、orientation、floor / wall source、atlas coordsまで反映される。
- Generator Overlay applyも `HexTileMapLayer.apply_overlay_data()` に接続され、plain `TileMapLayer` 必須ではなくなった。計画レビューではOverlay統合を段階分離する懸念があったため、これは計画以上の進捗として扱える。
- test runnerのrun directory分離と `TEST_JOBS` 対応により、`.godot_user` 配下の並列実行競合も同時に整理されている。

## 要件に対する不足

- editor analog確認が未記録である。headless testは「全量redrawへ戻っていない」ことを検証するが、Godot editor上のclick体感、hover/highlightの見え方、表示blinkの有無は別確認が必要。
- `HexTileMapLayer` の `hex_map` Resourceは完全なlazy snapshotではなく、互換用にcell単位で同期されている。現実的な互換設計としてはよいが、設計文書上は「Resourceをlive transportにしないが、inspector/export互換snapshotとして保持する」と明記したほうが誤解が少ない。
- `apply_document()` / `load_document_resource()` はload時の全量反映として残っている。per-click経路ではないため問題ではないが、次に大規模document load性能を扱う場合は別要件に分ける。
- `EditorUndoRedoManager` 連携は今回もheadless `UndoRedo` の検証までで、Godot editor plugin本体のUndo stack連携は別課題である。

## UX上の改善点

- Target Statusに、Primary map / Overlayがどちらも `HexTileMapLayer` 内部layerへ書かれていることを表示すると、ユーザーがplain `TileMapLayer` を探す必要がなくなる。
- Apply後のstatusに「synced from HexTileMapLayer state」「saved document snapshot」相当の短い結果を出すと、内部state化後のSave / Export境界が理解しやすい。
- Overlay apply時は、対象が `HexTileMapLayer` の場合に「base map layer」ではなく「overlay layerへ適用した」ことが分かる文言に寄せると、Primary applyとの混同を減らせる。
- 大きめmapのmanual editでは、Last Editに「changed cell」「renderer」「full redrawなし」を残す現在のdebug情報を、analog test手順にそのまま使える。

#### ユーザー意見

Overlayに関して、新規layer追加を名前付きで複数回行えるようにしたい。Floor / Wallに対する修飾用Tileのlayerや、それらと位置が重なる可能性のあるMap Object配置用layerや、Effect、ゲームUIに関連するlayerなど、複数のマップレイヤーがありうる。各Overlayの上下関係もコントロールできるようにしたい。挙げたものすべてについて、TileMapLayerの責務とするべきかはGodot開発の先例も調査する必要があるが、順序付き複数Overlayは自然な考えだと思う。編集対象の選択には、HexTileMapLayerと独立に、その配下の各Primay/Overlay選択を意図的にできる必要がある。(現状のEdit方法選択による自動切り替えだけではなく)

## 機能・コード上の改善点

- `_apply_hex_tile_map_layer_edit_command()` はtarget apply成功後にdocument更新する順序へ変えると、失敗時のdocument / target乖離を避けられる。
- Generator Primary applyは `hex_map` setterでも動くが、計画名に合わせて `load_map_resource()` 呼び出しへ揃えると、state API境界が読み取りやすい。
- command Dictionaryのkeyは現状testで守られている。payload種類が増える段階では、command builder / validator helperを1箇所に寄せると、無効commandの失敗理由をUIへ出しやすい。
- `apply_document_cell()` は互換helperとして適切に軽量化されている。今後は通常経路から呼ばれないことをsource検査またはCounting testで維持すればよい。

## 完了事項

- `HexTileMapLayer` に `load_map_resource()` / `load_document_resource()` / `to_map_resource()` / `to_document_resource()` / `cell_edit_state()` / `apply_edit_command()` / `inverse_edit_command()` が追加された。
- `set_cell_exists()` / `set_wall_state()` により、manual editの差分state更新が可能になった。
- `apply_document_cell()` は互換helperとして残しつつ、document duplicate / `to_map_resource()` / `_normalize_data()` を通常cell apply経路から外した。
- Hex targetのUndo / Redoはcommand / inverse commandでdocumentとtarget stateを戻す。
- Save / Export前にHex target内部stateからdocument snapshotへ同期する。
- Generator Primary / Overlay applyが `HexTileMapLayer` に接続された。
- `tests/test_hex_tile_map_layer.gd` で command / inverse command とsnapshot出力が検証された。
- `tests/test_editor_plugin.gd` で manual edit / Undo / Redoが `apply_document_cell()` と全量 `_redraw()` に戻らないこと、Generator Primary / Overlayが `HexTileMapLayer` に適用されることが検証された。

## 次計画へ残す事項

- editor analog testとして、大きめmapでmanual edit / Undo / Redo / Overlay applyの体感と表示blinkなしを記録する。
- `_apply_hex_tile_map_layer_edit_command()` のdocument更新順序をtarget apply成功後に寄せる。
- Generator Primary applyを明示的な `load_map_resource()` 呼び出しへ揃えるか、`hex_map` setterを互換入口として説明する。
- Target Status / Apply Statusの文言を、`HexTileMapLayer` 内部base layer / overlay layer / document snapshot境界が分かるように整理する。
- `EditorUndoRedoManager` 連携は、headless `UndoRedo` とは別にGodot editor plugin統合課題として扱う。

## 検証

- `./tools/test.sh`
  - `test_hex_core.gd: all tests passed`
  - `test_hex_map_generation.gd: all tests passed`
  - `test_hex_adapter.gd: all tests passed`
  - `test_hex_tile_map_layer.gd: all tests passed`
  - `test_editor_plugin.gd: all tests passed`
  - `test_debug_scenes.gd: all tests passed`
- `TEST_JOBS=2 ./tools/test.sh`
  - 上記全test pass。
  - `.godot_user/test-runs/<run-id>/logs` 配下へlogが分離されることを確認した。

macOS環境のCA certificate warningと既知の`push_warning`は発生したが、test失敗にはつながっていない。
