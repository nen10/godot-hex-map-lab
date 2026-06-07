# CLEAN-10 Self Review

Task: `CLEAN-10_DOCUMENT_CANONICAL_SCHEMA`
Status: PASS
Date: 2026-06-07

## Scope reviewed

- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`
- `docs/api/API_REFERENCE.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_SCRIPTING.md`
- `docs/TEST.md`
- `examples/basic_runtime/README.md`
- `examples/editor_workflow/`

## Acceptance review

| Acceptance | Status | Evidence |
|---|---|---|
| `v1` / `v2` / `version` removed from document public contract | PASS | `HexMapDocumentResource` no longer exports version constants or field; current document docs/tests use canonical wording. |
| Legacy document fields removed | PASS | `map`, `tile_overrides`, `objects`, and `labels` removed from `HexMapDocumentResource`; adapter no longer reads/writes them. |
| `ensure_v2_defaults()` removed from document contract | PASS | Document resource no longer defines it; editor/generator/examples/tests no longer call it for documents. |
| New document canonical by construction | PASS | `HexMapDocumentResource._init()` creates metadata and exposes only canonical arrays. |
| Tests verify canonical save/load and roundtrip, not migration fixtures | PASS | Adapter tests now cover canonical resource save/load, adapter roundtrip, mutation, and deleted-cell cleanup; migration fixture tests removed. |

## UX distortion check

No compatibility or headless-test requirement was preserved over the clean API. The old migration guide was deleted from current manuals instead of being retained as a public workflow.

## Test proof

`./tools/test.sh` passed on Godot `v4.6.2.stable.official.71f334935`.

See `docs/review/autopilot/CLEAN-10_TEST_RESULT_2026-06-07.md`.

## Search proof

Current document source/tests/docs were scanned for removed document API names:

- `migrate_v1_to_v2`
- document `ensure_v2_defaults`
- `VERSION_V1` / `VERSION_V2`
- `is_v2()`
- `v2_schema_fields()`
- direct `document.map`, `document.tile_overrides`, `document.objects`, `document.labels`

Remaining hits are object database `ensure_v2_defaults()` tests and implementation, which are outside CLEAN-10 and owned by later object database cleanup.

## Classification

- `repair-now`: complete
- `follow-up-ready`: none beyond dependency sweep
- `known-env-failure`: none
- `accepted-risk`: object database v2/legacy vocabulary remains for `CLEAN-12`
- `manual-optional`: none

## Queue sweep

Promote direct dependents of `CLEAN-10` whose dependencies are now complete:

- `CLEAN-11`
- `CLEAN-13`
- `CLEAN-12`
- `CLEAN-14`
