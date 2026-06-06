# Schema Boundary Decisions

作成日: 2026-06-07
Queue task: `P0-02`
Source matrix: `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
Source risks: `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`

## Summary

Level Document v2 should preserve v1 `.tres` compatibility while moving primary authoring data into typed resources. Current `Array` payloads remain migration inputs and compatibility outputs. Normal UX should move toward catalog keys, layer roles, object definitions, dependency records, and explicit validation results.

## Boundary Principles

1. Saved v1 resources must load.
2. v2 document fields should be typed resource arrays or typed resource references where Godot export support allows it.
3. Document content stores logical authoring intent; catalog and database resources store asset resolution details.
4. Raw `source_id / atlas_coords` stays available only as a legacy/advanced fallback after catalog-backed UX exists.
5. `HexTileMapLayer` is the primary roadmap target; plain `TileMapLayer` remains compatibility.
6. Fallback display is never validation success.

## Maintain / Migrate / Remove Decisions

| Current field or behavior | Decision | v2 destination | Compatibility rule | Follow-up task |
| --- | --- | --- | --- | --- |
| `HexMapDocumentResource.version` | Maintain and increment. | `version = 2` for v2 documents. | Missing or `1` means v1 migration input. | `LD2-01`, `LD2-02`. |
| `HexMapDocumentResource.map` | Maintain as v1 input and simple map resource export. Migrate primary authoring into terrain layer data. | `terrain_layers`, with one default terrain layer preserving cells/walls/orientation/cyclic size. | v1 `map` converts into the default terrain layer; adapter can still export a v1-compatible `map`. | `LD2-01`, `LD2-02`, `LD2-04`. |
| `tile_overrides` floor/wall entries | Migrate. | Terrain layer tile assignments keyed by cell and logical tile key, with optional legacy numeric fallback. | v1 entries preserve numeric values during migration; catalog-backed keys are preferred when available. | `LD2-01`, `CAT-01`, `CAT-03`. |
| `tile_overrides` overlay entries with `kind=overlay` | Migrate. | `overlay_layers`, each with layer id, display role, z/order, item key, cells, and catalog key mapping. | v1 overlay entries become one default overlay layer grouped by `item_key`. | `LD2-01`, `LST-01`, `LST-02`, `CAT-03`. |
| `objects` array | Migrate. | `object_placements`, with object id, cell, rotation, variant, properties, spawn condition, and runtime/export flags. | v1 object marker entries become placements with default rotation/variant/spawn condition. | `OBJ-01`, `OBJ-02`. |
| `labels` array | Migrate. | Typed label placements with label id, cell, text, display style key, and optional zone reference. | v1 label entries become typed labels preserving id/text/cell. | `LD2-01`, `LD2-03`. |
| `HexObjectDatabaseResource.objects: Array` | Migrate. | Object definition resources or typed definition entries. | Existing arrays load through migration/fallback. | `OBJ-01`. |
| `HexLabelDatabaseResource.labels: Array` | Migrate. | Label definition resources or typed definition entries only if labels need shared definitions; otherwise keep document label placements typed. | Existing arrays load through migration/fallback. | `LD2-01`, `VAL-01`. |
| Plain `TileMapLayer` direct apply | Maintain as compatibility. | Adapter fallback path outside primary layer stack. | Existing tests and explicit plain target behavior remain. | `LD2-04`, `CAT-04`. |
| Numeric tile controls in Generate/Edit Dock | Maintain temporarily; remove from normal UX after catalog selectors exist. | Advanced fallback UI and debug report details. | Existing behavior remains until `CATUI-01`; no silent removal. | `CATUI-01`, `CAT-04`. |

## TileSet Boundary

| Concern | Decision |
| --- | --- |
| TileSet resource reference | Store as dependency metadata or catalog dependency, not directly inside each document tile entry. |
| `source_id`, `atlas_coords`, `alternative_tile` | Store in `HexTileCatalogEntry` and legacy fallback payloads, not as normal v2 authoring values. |
| TileSet atlas tile preview | Catalog/UI responsibility. |
| TileSet terrains/autotile variants | Catalog/adapter responsibility; terrain layer stores logical tile keys and optional role tags. |
| Shared TileSet clone policy | Editor target/layer stack responsibility; document records dependencies and catalog keys. |

## Scene / Object Boundary

| Concern | Decision |
| --- | --- |
| Object scene path | Store in object database definition, not each placement unless overriding. |
| `TileSetScenesCollectionSource` entries | Catalog/object-layer adapter may resolve them; document placement stores `object_id` and cell intent. |
| Direct scene instances | Runtime/object adapter responsibility, selected by object definition policy. |
| Object marker rendering | Compatibility/debug display only until object layer adapter exists. |
| Object gameplay properties | Placement properties are typed per placement; definition default properties live in object database. |

## Custom Data Boundary

| Concern | Decision |
| --- | --- |
| TileSet custom data reading | Catalog validation/custom data reader responsibility. |
| Movement cost/blocking data | Catalog tags/custom data feed `HexMovementProfileResource` and validation; document may store overrides by logical key or zone, not raw TileSet custom data. |
| Validation of missing custom data | Validation engine reports catalog or profile-specific warnings/errors. |

## Validation Boundary

Validation should use a serializable result schema with:

- severity: `error` / `warning` / `info`
- rule id
- message
- scope: document / layer / cell / object / dependency
- cell or object id when scoped
- dependency path or catalog key when relevant

This belongs in `LD2-03` as schema and in `VAL-01` as rule execution.

## Layer Stack Boundary

`HexLayerStackResource` should own layer templates and roles:

- terrain
- decoration
- object
- collision
- navigation
- overlay
- debug

`HexMapDocumentResource` v2 should store layer content and desired role references. It should not encode internal child node names from current `HexTileMapLayer`.

## P0-02 Follow-Up Map

| Decision area | Direct consumer |
| --- | --- |
| Typed v2 document fields | `LD2-01` |
| v1 migration rules | `LD2-02` |
| Summary/validation result schema | `LD2-03` |
| v2 adapter roundtrip | `LD2-04` |
| Catalog keys and tile resolution | `CAT-01`, `CAT-03`, `CATUI-01` |
| Layer roles/templates | `LST-01`, `LST-02` |
| Object definitions/placements | `OBJ-01`, `OBJ-02`, `OBJ-04` |
| Validation execution/dashboard | `VAL-01`, `VAL-02` |

## No Human Approval Required

These decisions follow the validated roadmap and existing policy. They intentionally avoid public release, external credentials, destructive actions, and compatibility-breaking removal.
