# UI 実行パス確認メモ

対象: `docs/manual/MANUAL_EDITOR_PLUGIN.md` と `docs/manual/MANUAL_WORKFLOW.md` の日本語化にあたり、マニュアル上の実施項目が UI から実行できるかをコードベースから確認した結果。

確認日: 2026-06-19

## 確認範囲

静的なコード読解と既存テストの確認です。Godot エディターを手動起動した画面確認ではありません。

主に確認したファイル:

- `addons/hex_map_kit/plugin.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
- `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
- `addons/hex_map_kit/editor/hex_map_validate_screen.gd`
- `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
- `addons/hex_map_kit/editor/hex_map_export_screen.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `tests/test_editor_workspace.gd`
- `tests/test_editor_document.gd`
- `tests/test_editor_catalog.gd`
- `tests/test_editor_layer.gd`
- `tests/test_editor_paint.gd`
- `tests/test_editor_object.gd`
- `tests/test_editor_validate.gd`
- `tests/test_editor_qa.gd`
- `tests/test_editor_output.gd`
- `tests/test_editor_asset.gd`
- `tests/test_editor_distribution.gd`

## 結果サマリー

| 項目 | 判定 | 根拠/補足 |
|---|---|---|
| Workspace dock とタブ構成 | 成立 | `plugin.gd` が `HexMapWorkspace` dock を追加し、`hex_map_workspace_component_registry.gd` が `Build`, `Paint`, `Catalog`, `Layers`, `Resources`, `Validate`, `QA`, `Export`, `Settings` を返します。`Generate` は `Build` の互換 alias です。 |
| Resources の作成/選択/保存 | 成立 | `hex_map_workspace.gd` が Resources asset panel と missing unique resources panel を mount し、factory が Level Document、Catalog、Object DB、Label DB、Layer Stack、Profile 系 resource を作成します。`tests/test_editor_document.gd` と `tests/test_editor_workspace.gd` に UI contract が確認されています。 |
| `Create Missing Resources` | 成立 | 選択中 `HexTileMapLayer` に対して Level Document と Layer Stack を作成し、既存共有リソースを維持するテストがあります。 |
| Build graph 実行 | 成立 | `hex_map_build_screen.gd` に graph canvas、`Generate`、`Generate (Simple)`、preview、promote path があります。`tests/test_build_graph_canvas.gd` が primary surface と実行/preview を確認しています。 |
| 旧 Generate の preview / apply to selected Document | 成立 | `hex_map_gen_dock.gd` に output target、`Preview only`、`Apply to Document` があり、`tests/test_editor_generation.gd` が preview-only と selected document apply を区別して確認しています。日本語版では主導線を Build とし、旧 Generate は互換/補助パスとして記述しました。 |
| Catalog の TileSet 割り当て、atlas/scene entry 作成、検証 | 成立 | `catalog_screen_snapshot()` と catalog component が visual board、entry detail、validate を持ち、`tests/test_editor_catalog.gd` が arbitrary project TileSet、atlas entry、scene entry、preview、validate を確認しています。 |
| Paint の terrain/object/label 編集 | 成立 | `hex_map_edit_tool.gd` が brush palette と viewport input path を持ち、`tests/test_editor_paint.gd` が catalog/object/label brush、viewport click、document/target/display update を確認しています。 |
| Paint の Undo / Redo | 部分成立 | `hex_map_edit_tool.gd` に UndoRedo 接続と do/undo method 登録があります。ただし、今回確認した範囲では「UI からの完全な visible tile rollback」を直接断言する専用テストは見つけていません。本文では code path 上の接続ありとして注意書きにしました。 |
| Object DB / Label DB の typed UI | 成立 | `tests/test_editor_object.gd` が Object DB、Label DB、PackedScene definition、typed property controls を確認し、raw JSON/text を通常 UI から外していることも確認しています。 |
| Layer Stack の template、role 編集、create/apply/clear | 成立 | `hex_map_layers_screen.gd` と `hex_tile_map_layer.gd` に role stack UI と apply path があり、`tests/test_editor_layer.gd` が templates、role metadata、Create Missing Layers、Apply Document、Clear Role を確認しています。 |
| Validate の run、issue table、focus action | 成立 | `hex_map_validate_screen.gd` と `run_validate_screen()` が issue navigator を提供し、`tests/test_editor_validate.gd` が resource/catalog/layer/cell issue routing を確認しています。 |
| QA Seed Lab の batch、score table、selected preview、promote | 成立 | `hex_map_qa_screen.gd` に Seed Lab panel があり、`run_qa_seed_lab()`, `select_qa_seed_row()`, `promote_qa_selected_seed_to_document()` が Workspace にあります。`tests/test_editor_qa.gd` が batch rows、preview、promotion、Resources の Level Document 更新を確認しています。 |
| Export の Runtime Map / Runtime Scene / Generation Graph | 成立 | `hex_map_export_screen.gd` は 3 つの purpose card を定義します。`tests/test_editor_output.gd` が `HexMapResource`, `PackedScene`, `HexGenerationGraphResource` の書き出しと load を確認しています。 |
| Export destination | 成立 | `export_destination_dialog_config()` は Save File FileDialog を使い、editable path text を primary input にしません。`tests/test_editor_output.gd` が destination 未選択時の block と選択後の export を確認しています。 |
| Debug Report | 成立。ただし配置が現行化済み | Workspace debug report は `Export` の secondary action `Debug Report` として確認されています。`hex_map_edit_tool.gd` には Paint tool 側の `Copy Debug Report` もあります。旧マニュアルの「Validate/debug-report flow only」表現は現行 UI とずれるため、日本語版では Export secondary/diagnostic action として記述しました。 |
| Settings / Samples | 成立 | `Learn with bundled samples` は Settings へ遷移しますが sample mode を有効化しません。`hex_map_sample_settings_panel.gd` の toggle と `Duplicate To Project`、`tests/test_editor_asset.gd` と `tests/test_editor_workspace.gd` が sample は learning source であり production fallback ではないことを確認しています。 |
| Distribution Editor | 成立。旧 Generate 補助 | `hex_map_gen_dock.gd` の `Markov Mesh Rule Set` の `Edit` から `HexDistEditor` を開く path があり、`tests/test_editor_distribution.gd` が load/save/duplicate/recent/FileDialog contract を確認しています。 |
| Runtime Query / Runtime Object Export | UI 項目ではなく API/サンプル導線 | マニュアル該当節は script-side 使用例です。エディター UI 実行項目ではないため、UI 成立判定からは分けました。 |

## 日本語版で反映した差分

- 現行タブ名は `Build` です。`Generate` は互換 alias / Build 内補助として説明しました。
- Export は単一の Runtime Handoff ではなく、`Runtime Map Resource`, `Runtime Scene`, `Generation Graph` の 3 目的に更新しました。
- Debug Report は現行 UI では Export secondary action と Paint tool 側 copy path があるため、その位置づけに変更しました。
- Samples は learning/onboarding と project duplicate のための導線であり、production fallback ではないと明記しました。
- Undo / Redo は code path は確認できるが、今回の静的確認では完全な視覚 rollback の専用 UI テストを確認できなかったため、注意書きを入れました。
