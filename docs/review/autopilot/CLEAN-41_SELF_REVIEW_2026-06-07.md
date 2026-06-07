# CLEAN-41 Self Review

## Scope

- Reordered and rewrote API/runtime docs so `HexMapDocumentResource` and Resource object APIs are the first documented path.
- Updated runtime sample wrapper to accept `HexMapDocumentResource` directly through `document` / `run_example()`.
- Kept path helpers as explicit supplemental load helpers through `query_document_path()`, `load_document_path()`, `document_path`, and `run_path_example()`.
- Updated debug-scene tests to verify Resource-first query and path helper behavior.

## Acceptance

- Public API docs do not describe old versioning, migration, or compatibility concepts as public vocabulary.
- `HexRuntimeQuerySample.query_document()` appears before `query_document_path()` in API docs and source order.
- `HexTileMapLayer.load_document_resource()` appears before `load_document_path()` in API docs.
- Runtime README, scripting manual, and workflow manual show document Resource query first.
- Path helpers are documented only as supplemental saved-resource load helpers.
- Catalog `source_id` / `atlas_coords` are documented as atlas-entry details behind catalog keys, not the gameplay-facing vocabulary.

## Verification

- `git diff --check` PASS.
- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- Existing macOS `get_system_ca_certificates` errors and editor warning fixtures remain non-fatal known output.

## Review Result

- repair-now: none.
- follow-up-ready: none.
- known-env-failure: none.
- accepted-risk: path helper function names remain public because loading by saved resource path is still useful for runtime scenes and tests; docs clearly mark them supplemental.
- manual-optional: none.
