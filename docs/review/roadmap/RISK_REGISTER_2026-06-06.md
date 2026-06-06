# Roadmap Risk Register

作成日: 2026-06-07
Queue task: `P0-01`
Source matrix: `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`

## Risk Summary

| id | Risk | Severity | Current signal | Mitigation / next task | Classification |
| --- | --- | --- | --- | --- | --- |
| `R-SCHEMA-ARRAY-001` | Object, label, and tile payloads continue growing as untyped `Array` dictionaries. | High | `HexMapDocumentResource` v1 fields are `tile_overrides`, `objects`, `labels`; object/label database resources expose `Array` only. | `P0-02` boundary decisions, then `LD2-01` typed v2 schema and `LD2-02` migration. | repair by roadmap task |
| `R-TILE-NUMERIC-002` | Normal UX remains coupled to `source_id / atlas_coords`, making documents fragile across TileSet changes. | High | Generate/Edit controls and document overrides store numeric tile coordinates. | `CAT-01` catalog resource, `CAT-03` catalog-backed adapters, `CATUI-01` selectors. | repair by roadmap task |
| `R-LAYER-ROLE-003` | `HexTileMapLayer` child layers are internal implementation detail, not author-facing layer roles. | High | Runtime layer has base/loop/overlay internals but no `HexLayerStackResource`. | `LST-01` layer stack resource, `LST-02` document apply to stack. | repair by roadmap task |
| `R-DOC-VERSION-004` | Saved v1 `.tres` documents may become incompatible if v2 is added without explicit migration. | High | `version: int = 1` exists, but no migration helper or compatibility policy. | `LD2-02` migration helper and roundtrip/missing-field tests. | repair by roadmap task |
| `R-VALIDATION-005` | Missing catalog/object/dependency errors cannot be surfaced before runtime/editor apply. | High | No validation result schema or dashboard; current adapters skip or fallback in several paths. | `LD2-03` validation result schema, `VAL-01` rules, `VAL-02` dashboard. | repair by roadmap task |
| `R-EDITOR-COUPLING-006` | Adding catalog, validation, object, and QA UI directly to giant dock files will increase regression risk. | Medium | Generate Dock, Edit Tool, and editor test files are each thousands of lines. | Run `ARCH-*` companion refactors when feature tasks would add broad state logic. | accepted risk with mitigation |
| `R-RUNTIME-QUERY-007` | Existing path/highlight helpers do not represent movement profile costs or blockers. | Medium | Runtime helper has path/highlight APIs but no movement profile resource. | `GAME-01` movement profile, `GAME-02` weighted path/range. | repair by roadmap task |
| `R-OVERLAY-DOC-008` | Overlay generation is strong, but document overlay layers are represented as tile override entries rather than first-class layers. | Medium | `HexOverlayResource` exists separately; `HexMapDocumentResource` has no overlay layer field. | `LD2-01` overlay layer schema, `CAT-03` overlay catalog adapter, `LST-02` apply path. | repair by roadmap task |
| `R-OBJECT-RUNTIME-009` | Object mode currently creates markers, not scene placements or runtime entities. | Medium | Object payload stores `object_id` and properties; no scene path or placement adapter. | `OBJ-01` object database v2, `OBJ-02` placement schema, `OBJ-04` object layer adapter. | repair by roadmap task |
| `R-TEST-ENV-010` | Local `./tools/test.sh` may be blocked when Godot is not available. | Medium | `AUTO-00_TEST_RESULT_2026-06-06.md` recorded missing Godot binary. | `P0-03` baseline environment report; use `GODOT_BIN` when available. | known-env-failure candidate |

## Dependency Notes

- `P0-02` is the next docs task because it turns this register into concrete maintain/migrate/remove decisions.
- `P0-03` must not be skipped. Implementation phases should not be marked complete without a real test baseline or an explicit `BLOCKED_BY_TEST_ENV`.
- `LD2-01` should consume both this register and `SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md`.

## Nonblocking Accepted Risks

| Risk | Reason accepted for P0-01 | Release condition |
| --- | --- | --- |
| Current giant editor files remain unchanged. | P0-01 is docs-only classification and does not add coupling. | Feature tasks that add broad state logic should trigger `ARCH-*` before widening those files. |
| No automated test added. | P0-01 changes no code behavior. | First code/schema task must add or update Test path coverage. |
