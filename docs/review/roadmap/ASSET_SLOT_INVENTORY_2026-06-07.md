# Asset Slot Inventory 2026-06-07

Roadmap: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/ROADMAP.md`  
Queue task: `ASSET-01_ASSET_SLOT_INVENTORY`

## Scope

This inventory records current editor-facing asset slots and asset-like authoring inputs before the asset slot model and workspace tab migration. It classifies whether the current UI supports arbitrary project assets, depends on bundled samples/presets, exposes raw/debug controls, or lacks the planned slot entirely.

Source review:

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres`

## Current Workspace Shape

The workspace registry exposes `Document`, `Generate`, `Paint`, `Catalog`, `Layers`, `Validate`, `QA`, and `Export` tabs. Current implementation mounts `HexMapGenDock` only into `Generate` and mounts `HexMapEditTool` only into `Paint`; the other tabs are mostly responsibility labels until `WORKSPACE-10`.

## Flow Classification

| classification | meaning |
|---|---|
| `main` | Intended production authoring path exists, though it may still be in the wrong tab. |
| `mixed` | Production path exists but is mixed with sample/preset/raw/debug behavior. |
| `sample` | Bundled sample or built-in preset path; not production completion proof. |
| `debug` | Support/advanced/raw route that should not be normal authoring UX. |
| `missing` | Planned asset slot has no current UI slot. |

## Inventory

| slot_id | screen/tab | current UI | required asset type | current sample dependency | current arbitrary selection path | missing/invalid validation | flow classification | cleanup task id |
|---|---|---|---|---|---|---|---|---|
| `document.resource` | Paint now; should be Document | `New Document`, `Document Resource` picker, `Open...`, `Save`, `Save As...`, read-only saved path | `HexMapDocumentResource` | none | Yes: `EditorResourcePicker`, open/save `EditorFileDialog`, create-new in memory | `No document selected`, `Document path is empty`, wrong resource type status, validation dashboard | `main` | `SCREEN-20`, `WORKSPACE-10` |
| `document.import_map` | Paint now; should be Document advanced/convert | `Convert Resource` picker, `Browse...`, `Convert`, read-only import saved path | `HexMapResource` | none | Yes: `EditorResourcePicker` or `.tres` FileDialog | unsupported/missing path status; convert fails if not `HexMapResource` | `debug` | `SCREEN-20` |
| `document.validation_current` | Paint now; should be Validate | `Validate` button plus dashboard rows/focus | current `HexMapDocumentResource` and dependencies | no direct sample UI, but catalog option may be sample-loaded | No validation suite asset slot; validates current document/context only | `No document selected`, grouped validation rows and focus status | `mixed` | `SCREEN-25`, `ASSET-11` |
| `export.destination` | Paint now; should be Export | `Export Saved` read-only path, `Export...`, `Export As...` | `HexMapResource` destination `.tres` path | none | Yes: save `EditorFileDialog` | `No document selected`, `Export path is empty`, save error status | `main` | `SCREEN-27`, `WORKSPACE-10` |
| `workspace.target_layer.edit` | Paint | `Target` option, `Refresh`, auto or explicit scene target | `TileMapLayer` / `HexTileMapLayer` scene node | none | Partial: scene scan/selection, not a project asset Resource | `No editable target layer`, `Target is not a TileMapLayer`, readiness status | `main` | `WORKSPACE-10`, `SCREEN-20`, `SCREEN-22` |
| `workspace.target_layer.generate` | Generate | `Target Layer` option, `Refresh`, add layer option | `TileMapLayer` / `HexTileMapLayer` scene node | none | Partial: scene scan/add, not a project asset Resource | target missing errors in apply/sample paths | `main` | `WORKSPACE-10`, `ASSET-11` |
| `layer_stack.template` | Paint now; should be Layers | `Template` option with `Standard Authoring` / `Minimal Runtime` | `HexLayerStackResource` | built-in templates, no bundled project asset | No project resource picker/create path | status shows role count and target; missing role rows show `missing` | `mixed` | `SCREEN-22`, `ASSET-10`, `ASSET-12` |
| `layer_stack.role_targets` | Paint now; should be Layers | role tree, `Create Missing Layers`, `Apply Document`, `Clear Role` | target `HexTileMapLayer` role layers | none | Scene target only; no saved layer stack project asset | requires `HexTileMapLayer` target and document; role row `missing` status | `main` | `SCREEN-22`, `WORKSPACE-10` |
| `catalog.resource` | Paint now; should be Catalog | `Catalog Resource` picker | `HexTileCatalogResource` | Silent fallback loads `res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres` when no catalog is selected | Yes, but sample fallback hides unconfigured state | catalog validation summary; missing state often hidden by `_ensure_tile_catalog()` | `mixed` | `SCREEN-21`, `SAMPLE-10`, `ASSET-10` |
| `catalog.tileset` | Paint now; should be Catalog | `TileSet` picker under Catalog | `TileSet` | sample catalog embeds a sample `TileSet` | Yes: `EditorResourcePicker` | catalog status `TileSet=yes/no`; validator reports missing TileSet/source/coords | `mixed` | `SCREEN-21` |
| `catalog.scene_entry_resource` | Paint now; should be Catalog/Object | `Scene Entry Resource` picker, `Add Scene Entry` | `PackedScene` | sample catalog includes `sample_spawn_marker.tscn` scene entry | Yes: `EditorResourcePicker` | selected resource type status; entry preview says `missing scene`; validator reports missing scene | `mixed` | `SCREEN-21`, `SCREEN-23` |
| `catalog.entries` | Paint now; should be Catalog | entry tree, `Add Atlas Entry`, `Add Scene Entry`, `Validate Catalog` | `HexTileCatalogEntry` resources inside catalog | sample catalog provides `terrain.floor`, `terrain.wall`, `overlay.treasure`, `object.spawn_marker` | Partial: entries can be added to selected catalog, but no full entry editor/create-save flow | row status from `HexTileCatalogValidator` | `mixed` | `SCREEN-21`, `ASSET-12` |
| `target.tileset` | Paint | `Target TileSet / Atlas` `TileSet` picker | `TileSet` applied to selected target layer | none directly, but sample/preset atlas can create target TileSet content nearby | Yes: `EditorResourcePicker` | `No editable target TileSet`, target readiness `TileSet missing` | `main` | `SCREEN-21`, `SCREEN-22` |
| `target.atlas_image` | Paint and Generate | read-only atlas path plus `Browse` / `Browse Atlas Image`, `Apply Atlas` | image texture atlas path | adjacent sample/preset buttons; default tile size uses sample size | Yes: image `EditorFileDialog` | `Failed to apply target atlas`, missing editable target | `mixed` | `SCREEN-21`, `SAMPLE-10` |
| `target.atlas_presets` | Paint | `Sample` option with `Sample 64x57`, `Tactics Flat 64x57`, `Tactics Pointy 57x64`, `Apply Sample` | bundled atlas image + tile size preset | direct bundled asset dependency | No arbitrary project asset in this preset slot; arbitrary path exists as separate atlas browse | `No sample atlas selected`, apply failure status | `sample` | `SAMPLE-10`, `SAMPLE-11` |
| `generate.sample_tiles_button` | Generate | `Use Sample Tiles` | bundled sample atlas configured onto selected layer | direct `sample_hex_tiles.png`, source `0`, floor `(0,0)`, wall `(1,0)`, size `64x57` | No; separate `Browse Atlas Image` exists | errors if no selected layer | `sample` | `SAMPLE-10`, `SAMPLE-11`, `DOC-50` |
| `default.floor_wall_catalog_keys` | Paint | `Floor Catalog` / `Wall Catalog` options for default target tiles | catalog keys from `HexTileCatalogResource` | options are populated through sample catalog fallback | Project catalog can feed options only after selecting catalog; default state is sample-driven | fallback label `Choose catalog key`; readiness still has numeric fallback | `mixed` | `SCREEN-21`, `SCREEN-24`, `CLEANUP-30` |
| `default.floor_wall_numeric_tiles` | Paint | hidden `Floor Src`, `Wall Src`, atlas X/Y, alt spin boxes; read/apply target tiles | raw TileSet source id / atlas coords | initialized to sample-like source/coords | No project asset; debug raw numeric route | hidden in normal UI but still powers fallback/apply | `debug` | `CLEANUP-30` |
| `paint.tile_brush_catalog_key` | Paint | `Tile Catalog` option in Floor/Wall/Overlay tile modes | catalog entry key | populated through sample catalog fallback | Project catalog can feed options after selection; no owning Paint brush asset | fallback label, missing key returns no-op | `mixed` | `SCREEN-24`, `SCREEN-21`, `CLEANUP-30` |
| `paint.tile_brush_numeric_payload` | Paint | hidden `Tile Source`, atlas X/Y, alt spin boxes | raw TileSet source id / atlas coords | sample-like defaults | No project asset; debug raw route | hidden in normal UI; still used as fallback when catalog config missing | `debug` | `CLEANUP-30` |
| `paint.overlay_item_key` | Paint | raw `Overlay Item` LineEdit plus `Known` option | planned overlay definition/key | sample catalog has `overlay.treasure`; document can provide known keys | Partial: known option from current document, but no typed overlay definition asset | raw key accepts any text; no dedicated overlay DB validation | `mixed` | `SCREEN-24`, `CLEANUP-31` |
| `object.database` | Paint now; should be Objects/Labels | `Object DB` picker | `HexObjectDatabaseResource` | none directly; object key picker falls back to sample catalog if DB missing | Yes: `EditorResourcePicker` | status `No object database selected`; document validator can use object DB when provided | `main` | `SCREEN-23`, `ASSET-11` |
| `object.definition_key` | Paint | `Object Key` option and object definition tree | `HexObjectDefinitionResource` inside object DB | if no object DB, object keys come from sample tile catalog `object.spawn_marker` | Project object DB supports arbitrary definitions; fallback is sample catalog | empty key no-op; status shows definitions/selected | `mixed` | `SCREEN-23`, `SCREEN-24`, `SAMPLE-10` |
| `object.definition_scene` | Paint | `Definition Scene` picker | `PackedScene` | sample catalog references `sample_spawn_marker.tscn`; object DB path itself has no sample default | Yes: `EditorResourcePicker` | wrong type status; row preview `missing scene`; validator can report object scene missing | `main` | `SCREEN-23` |
| `object.raw_id` | Paint | raw `Object` LineEdit exists but is hidden in current normal Object mode | raw object id string | sample catalog fallback can supply key | No asset selection; superseded by object key/definition picker | hidden in normal mode; payload accepts raw text | `debug` | `CLEANUP-31`, `SCREEN-23` |
| `object.variant` | Paint | visible `Variant` LineEdit | planned typed variant/enum source | none | No typed asset/schema source | raw text accepted | `mixed` | `CLEANUP-31`, `SCREEN-23` |
| `object.properties` | Paint | hidden raw JSON `Properties`, visible typed `Placement Properties`, property table hidden | definition schema/default properties | none | Partial: typed controls generated from selected definition defaults; no standalone schema asset | raw JSON hidden; typed controls support bool/number/string/enum/resource | `mixed` | `CLEANUP-31`, `SCREEN-23` |
| `object.spawn_condition` | Paint | visible `Spawn` LineEdit | planned typed spawn condition definition/expression | none | No asset/schema source | raw text accepted | `mixed` | `CLEANUP-31`, `SCREEN-23` |
| `label.database` | Paint now; should be Objects/Labels | `Label DB` picker | `HexLabelDatabaseResource` | none | Yes: `EditorResourcePicker` | no visible status summary yet; validator can check label placement data separately | `main` | `SCREEN-23`, `ASSET-11` |
| `label.definition_key` | Paint | raw `Label ID` LineEdit; no definition picker/list | planned label definition in label DB | none | No typed label definition selection yet | raw text accepted | `mixed` | `SCREEN-23`, `CLEANUP-31` |
| `label.text` | Paint | `Text` LineEdit | label content, not an asset | none | Not an asset slot | raw label text accepted | `main` | `SCREEN-23` |
| `generate.tile_catalog_context` | Generate | no catalog resource picker; floor/wall/overlay options use `_ensure_tile_catalog()` | `HexTileCatalogResource` | silent sample catalog fallback | No Generate UI path for arbitrary catalog; can only be injected through shared/session/API later | missing catalog hidden by sample fallback; validation uses sample catalog | `mixed` | `ASSET-11`, `SAMPLE-10`, `SCREEN-26` |
| `generate.floor_wall_catalog_keys` | Generate | `Floor Catalog` / `Wall Catalog` options in Tile Settings | catalog entry keys | sample catalog keys populate default options | No Generate-owned project catalog selector | fallback to numeric tile config if catalog key missing | `mixed` | `SCREEN-21`, `SCREEN-26`, `CLEANUP-30` |
| `generate.overlay_item_pool` | Generate | `Target Item`, overlay item rows, item catalog options | overlay item definitions/catalog keys | default raw item; overlay catalog options from sample catalog | No overlay definition asset; catalog key options depend on hidden sample catalog | raw item names; empty query warnings in existing tests | `mixed` | `SCREEN-24`, `SCREEN-26`, `CLEANUP-31` |
| `generate.mapdata_source_registry` | Generate | `Source Registry`, `Browse .tres`, query source options | `HexMapResource` / `HexOverlayResource` | none | Yes: `.tres` FileDialog to register project resources | unsupported resource error; missing path warning; empty query warnings | `main` | `SCREEN-25`, `SCREEN-26` |
| `generate.overlay_query_sources` | Generate | Placement Mask / Deductor Floor / Adjacency Items query rows | selected source registry item + item key/query | none directly | Partial: depends on source registry project resources | empty query warnings; source row removal/reload state | `main` | `SCREEN-25`, `SCREEN-26` |
| `generate.adjacency_rule_set` | Generate | raw `Adjacency Rules` LineEdit plus `Edit` window | planned validation/generation rule Resource | built-in text default `default=0.0` | No project Resource slot; only raw text editor | parse status shows invalid entries | `debug` | `CLEANUP-31`, `SCREEN-26` |
| `generate.distribution_profile` | Generate / Distribution Editor | Markov Mesh Rule Set `Dist` option, `Edit`, preset list, `Load .tres`, `Duplicate Preset...`, recent custom paths | `HexDistribution` now; planned generation profile Resource | built-in distribution presets | Yes in editor window: load/save `.tres`; duplicate preset to project path | wrong loaded type ignored; save errors via `push_error` | `mixed` | `SCREEN-26`, `SAMPLE-11` |
| `generate.history_directory` | Generate | `History`, `History Dir`, history label | directory for generated resource snapshots | none | Yes: directory FileDialog | off/choose directory label; no project asset Resource | `debug` | `SCREEN-26` |
| `generate.output_resource` | Generate | `Save As .tres` for current generated map/overlay | `HexMapResource` / `HexOverlayResource` | generated data may carry sample catalog keys | Yes: save FileDialog | no-op if no generated resource; save error status | `main` | `SCREEN-26`, `SCREEN-27` |
| `qa.generation_profile` | Generate/QA | Seed Lab uses current Generate controls; no separate profile slot | planned generation profile Resource | current distribution presets may drive generation | No dedicated project profile selector/create path | blocked row reason if current generation snapshot invalid | `missing` | `SCREEN-26`, `ASSET-11`, `ASSET-12` |
| `qa.validation_suite` | Generate/QA | Seed Lab validates through built-in validator and `_generation_validation_options()` | planned validation suite Resource | validation options include sample catalog fallback | No project validation suite selector/create path | score table shows validation summary/errors/warnings | `missing` | `SCREEN-26`, `SCREEN-25`, `ASSET-11` |
| `qa.promotion_target` | Generate/QA | `Promote to Document` creates dirty document metadata from selected seed | `HexMapDocumentResource` / workspace document context | generated document can inherit sample catalog keys | Partial: creates document in memory; save path belongs to Document workflow | `No seed selected`, promotion failed/block reason | `mixed` | `SCREEN-26`, `ASSET-11` |
| `validate.rule_suite` | Validate | no validation rule suite asset UI; dashboard uses built-in validator | planned validation rule suite Resource | none directly, but validation options may include sample catalog | No project validation suite selection | dashboard reports current validator issues only | `missing` | `SCREEN-25`, `ASSET-11` |
| `settings.sample_mode` | Settings/Samples planned | no Settings/Samples tab or sample mode toggle | sample settings state | samples are currently always reachable from main UI | No | no mode state; sample controls not hidden when sample mode is off because mode does not exist | `missing` | `SAMPLE-10`, `SAMPLE-12` |
| `manual.sample_tiles_reference` | Manual | `Configure Sample Tiles And Atlases` documents `Use Sample Tiles`, sample path, source id, atlas coords, tile size | bundled sample assets | direct sample path reference | Manual also mentions browse atlas/project catalog route | documentation only | `sample` | `DOC-50`, `DOC-51` |

## Required Acceptance Classifications

- `Use Sample Tiles`: classified as `sample` in `generate.sample_tiles_button`; should move to Settings/Samples.
- target atlas presets: classified as `sample` in `target.atlas_presets`; arbitrary atlas browse exists separately.
- sample catalog keys: classified in `catalog.resource`, `default.floor_wall_catalog_keys`, `paint.tile_brush_catalog_key`, and Generate catalog rows; current silent `_ensure_tile_catalog()` fallback is the main issue.
- distribution presets: classified in `generate.distribution_profile`; project `.tres` load/save exists, but presets are still main-row options.
- object scene sample: classified in `catalog.scene_entry_resource`, `object.definition_key`, and `object.definition_scene`; bundled `sample_spawn_marker.tscn` is reachable through sample catalog fallback.
- manual sample references: classified in `manual.sample_tiles_reference`; later manual tasks must make sample mode learning/onboarding instead of normal setup.

## Cross-Cutting Gaps

- `HexMapEditorSessionState` only shares target/document/import/export paths today. Catalog, object DB, label DB, layer stack, movement profile, validation suite, and generation profile are not shared workspace context yet.
- Missing catalog state is often hidden by loading `sample_hex_tile_catalog.tres`; later completion proof must assert visible unconfigured state or project asset selection.
- Raw text remains in overlay item key, label id, object variant, object spawn condition, adjacency rule text, and hidden raw JSON properties.
- Numeric tile fallback still exists as hidden source/atlas controls and as fallback config when a catalog key fails.
- Document/Catalog/Layers/Validate/QA/Export tabs do not own their asset slots yet; current controls are concentrated in Paint and Generate.

## Follow-Up Ownership

- `ASSET-10`: create a slot state/control model that can express missing, selected, invalid, warning, and sample-source states.
- `ASSET-11`: create shared workspace asset context so Generate/Paint/Validate/QA do not independently load samples.
- `ASSET-12`: add create-new/save-as flows for project assets.
- `SAMPLE-10`: move samples/presets into Settings/Samples and add sample mode.
- `WORKSPACE-10`: move real content to owning tabs.
- `SCREEN-20` through `SCREEN-27`: replace screen-specific mixed/missing slots with project-asset-first workflows.
- `CLEANUP-30`: quarantine numeric fallback.
- `CLEANUP-31`: replace raw text authoring fields with typed selection/schema UI.
