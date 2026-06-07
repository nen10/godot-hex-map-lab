# CLEAN-30 Implementation Plan

作成日: 2026-06-07

## Scope

対象:

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_document_inspector.gd`
- `addons/hex_map_kit/editor/hex_map_validation_dashboard.gd`
- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_gen_state_evaluator.gd`
- `addons/hex_map_kit/editor/hex_map_edit_mutation_builder.gd`
- `tests/test_editor_plugin.gd`
- `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md`

対象外:

- product code の変更
- editor UI の削除
- headless test の削除・再設計
- `docs/TEST.md` 更新

## Steps

1. Queue の `CLEAN-30` を `RUNNING` にする。
2. plan packet を作る。
3. Editor source と editor tests を user task 別に inventory する。
4. Inventory doc で `keep-in-place` / `move-to-screen` / `merge-with-existing` / `advanced-only` / `delete` を分類する。
5. path text / fallback UI deletion candidates を明示する。
6. `./tools/test.sh` を実行する。
7. Test result と self-review を作成する。
8. Queue を `COMPLETE` にし、dependency sweep で次の `READY` task を明示する。
9. Completion commit を作る。
