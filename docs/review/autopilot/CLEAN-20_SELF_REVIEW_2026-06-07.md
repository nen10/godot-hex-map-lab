# CLEAN-20 Self Review 2026-06-07

Task: `CLEAN-20_RESOURCE_SELECTION_UI_STANDARD`

## Result

Status: `COMPLETE`

## Acceptance Review

| Requirement | Result | Evidence |
|---|---|---|
| Document/import selection does not require editable path text. | pass | `HexMapEditTool` uses document/import resource pickers when available, Browse fallback, and read-only saved-location fields. |
| Save As/export path selection is FileDialog-driven. | pass | Document Save As always opens the save file dialog handler; export keeps Save As and saved export status. |
| Session state is resource-first with optional saved paths. | pass | `HexMapEditorSessionState` stores `document`, `import_map`, and `*_saved_path` metadata. |
| Headless tests no longer require editable path controls. | pass | Editor UI smoke tests assert picker-or-Browse selection and read-only saved path status. |

## Repair Review

- `repair-now`: stale saved-path metadata could remain after replacing/clearing resources. Repaired by publishing saved-path updates explicitly and clearing document/import saved path state for unsaved resource replacements.
- `follow-up-ready`: broader old editor UI destruction remains covered by `CLEAN-50` and `CLEAN-33`.
- `known-env-failure`: none. The macOS CA certificate warning appears during Godot startup but does not fail tests.

## Tests

- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`
- `git diff --check` PASS

## Major Files

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `tests/test_editor_plugin.gd`
- `docs/knowledge/DEV_GODOT.md`
- `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-20_RESOURCE_SELECTION_UI_STANDARD/`

## Maturity

- `HEADLESS_TEST_COMPLETE`
