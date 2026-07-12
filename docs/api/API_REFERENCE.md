# Hex Map Kit API Reference

This page lists the public scripts and resources used by the current manuals and examples. It is intentionally concise; workflow steps live in `docs/manual/`.

The public vocabulary is Resource-backed: `HexMapDocumentResource` is the level document, catalog keys are the tile/object authoring vocabulary, and saved paths are supplemental load/save inputs.

## Core

### `HexVector`

Path: `res://addons/hex_map_kit/core/hex_vector.gd`

- `HexVector.zero()`
- `HexVector.q_axis()`, `s_axis()`, `r_axis()`
- `HexVector.apply_basis(q, s, r)`
- `HexVector.from_axial(q, r)`
- `axial() -> Vector2i`
- `add(other)`, `subtract(other)`, `scaled(amount)`
- `key()`

Use it as the canonical hex coordinate value for cells, paths, object placements, labels, and runtime queries.

`q` / `s` / `r` are public integer components. They are unit-basis coefficients, not cube
coordinates with `q + s + r == 0`. A shared slide `(q + k, s + k, r + k)` represents
the same hex, and `apply_basis(q, s, r)` normalizes it to the canonical form. For example,
`apply_basis(3, 1, 3)` equals `apply_basis(0, -2, 0)`, and `q_axis()` is `(1, 0, 0)`
even though its component sum is not zero.

`axial()` is the public axial conversion and returns `(q - s, r - s)`. `from_axial(q, r)`
is the inverse constructor and is equivalent to `apply_basis(q, 0, r)`. Reading `q`, `s`,
and `r` is public API, but external integrations should prefer `axial()` / `from_axial()`
when exchanging coordinates.

HexVector が採用する cannonical hex は hex cube 座標系とは異なる。cannonical hex の目的はL^1,L^2,L^∞を表現するさまざまな距離計算の導出を数学的に簡潔な他の表現によって取り出せることにある。計算経路を複数用意できる座標表現として有用である。

When you need display-space conversions (offset coordinates or `TileMapLayer` cells),
use `HexPoint` rather than `HexVector`.

### `HexPoint`

Path: `res://addons/hex_map_kit/core/hex_point.gd`

- `HexPoint.new(q, r)`
- `HexPoint.from_basis(q, s, r)`
- `HexPoint.from_offset(x, y)`
- `to_offset() -> Vector2i`
- `to_cell() -> Vector3i`
- `relative_cell(origin_z_order)`
- `add_vector(vector)`, `subtract_vector(vector)`
- `vector_from(other)`, `vector_to(other)`
- `l1_distance_to(other)`, `l2_distance_to(other)`
- `key()`

HexPoint is the display-facing position type. It bridges core `HexVector` coordinates
into display space: axial `(q, r)` components, offset coordinates, and `TileMapLayer`
cell / z-order values. Use `HexVector` for core math and storage; use `HexPoint` at the
rendering / authoring boundary.

`HexPoint.new(q, r)` takes the axial position directly as its constructor. `from_basis(q, s, r)`
accepts `HexVector` unit-basis coefficients (the same slide-equivalent triples as
`apply_basis`) and yields the axial point `(q - s, r - s)`; `from_basis(v.q, v.s, v.r)`
equals the point at `v.axial()`. `from_offset(x, y)` builds a point from offset
coordinates, while `to_offset()`, `to_cell()`, and `relative_cell(origin_z_order)` convert
back to offset / `TileMapLayer` cell / z-order values.

### `HexGrid`

Path: `res://addons/hex_map_kit/core/hex_grid.gd`

- `neighbors(hex, cyclic_size = 0)`
- `l1_ring(radius)`, `l1_disc(radius)`
- `shortest_path(start, goals, enterable_points, cyclic_size = 0)`
- `weighted_path(start, goals, enterable_points, costs, cyclic_size = 0)`
- `movement_range(start, enterable_points, movement_budget, costs, cyclic_size = 0)`

Use `cyclic_size` for toric maps.

### `HexMapData`

Path: `res://addons/hex_map_kit/core/hex_map_data.gd`

- `rectangle(width, height, toric = false)`
- `hexagon(radius)`
- `square(size, toric = false)`
- `from_cells(cells, walls = [], cyclic_size = 0)`
- `floor_cells()`, `wall_set()`, `cell_set()`

`HexMapData` stores existing cells and wall cells. Floor cells are `cells - walls`.

### `HexMapGenerator`

Path: `res://addons/hex_map_kit/core/hex_map_generator.gd`

- `generate_rectangle(width, height, wall_probability, seed = 0, connect_method = CONNECT_NONE, toric = false, protected_floor = [])`
- `generate_hexagon(radius, wall_probability, seed = 0, connect_method = CONNECT_NONE, protected_floor = [])`
- `generate_toric_square(size, wall_probability, seed = 0, connect_method = CONNECT_NONE, protected_floor = [])`
- `generate_symmetric_square(radius, wall_probability, seed = 0, connect_method = CONNECT_NONE, protected_floor = [], distribution_id = 20, terminal_floor = [], connect_toric = false)`
- `is_floor_connected(data)`
- `restore_connectivity_dense(data)`, `restore_connectivity_sparse(data)`, `restore_terminal_connectivity(data, terminal_floor)`

Use `CONNECT_DENSE` or `CONNECT_SPARSE` when generated maps should be connected before saving or applying.

## Resource And Adapter

### `HexMapResource`

Path: `res://addons/hex_map_kit/adapter/hex_map_resource.gd`

- `HexMapResource.from_map_data(data, orientation = ORIENTATION_FLAT_TOP)`
- `to_map_data()`
- exported fields: `cells`, `walls`, `cyclic_size`, `orientation`

This is the simple `.tres` wrapper for primary terrain maps.

### `HexMapDocumentResource`

Path: `res://addons/hex_map_kit/adapter/hex_map_document_resource.gd`

Canonical fields:

- `terrain_layers`
- `overlay_layers`
- `object_placements`
- `label_placements`
- `zones`
- `metadata` (created by default on new documents)
- `dependencies`

New documents are canonical by construction. Add terrain, overlay, object, label, zone, and dependency resources directly. Dependency resources hold a `resource` reference plus `kind`, `role`, and `required`; use the referenced resource's built-in `resource_path` only for debug display.

### `HexMapDocumentAdapter`

Path: `res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd`

- `from_map_resource(resource)`
- `to_map_resource(document)`
- `document_summary(document)`
- `document_tile_entries(document)`
- `document_object_entries(document)`
- `document_label_entries(document)`
- `validation_result_for_document(document)`
- `apply_to_tile_map_layer(document, layer, options = {})`

Use it as the boundary between saved documents and display/runtime helpers.

### `HexTileMapLayer`

Path: `res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd`

- `load_document_resource(document) -> bool`
- `load_document_path(path) -> bool`
- `apply_document(document)`
- `apply_document_to_layer_stack(document, layer_stack, options = {})`
- `find_weighted_path(start, goal, movement_profile = null)`
- `movement_range(start, movement_budget, movement_profile = null)`

Use `HexTileMapLayer` for runtime loading, display, loop-aware helpers, movement queries, and layer-stack application. Prefer `load_document_resource()` when the caller already has a `HexMapDocumentResource`; `load_document_path()` is a saved-resource convenience.

### `HexLayerStackResource`

Path: `res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd`

- `standard_template()`
- `minimal_runtime_template()`
- `role_names()`
- `first_layer_for_role(role)`
- `sorted_layers()`

Standard roles include terrain, decoration, object, collision, navigation, overlay, and debug.

### `HexTileCatalogResource`

Path: `res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd`

- `entry_for_key(key)`
- `has_key(key)`
- `keys()`
- `entries_with_tag(tag)`

Entries are `HexTileCatalogEntry` resources with `key`, `entry_type`, `scene`, `tags`, and `metadata`. Catalogs own a `TileSet` resource through `tile_set`; scene entries own a `PackedScene` resource through `scene`. Atlas entries also expose `source_id`, `atlas_coords`, and `alternative_tile` as TileSet entry details behind the catalog key.

### `HexObjectDatabaseResource`

Path: `res://addons/hex_map_kit/adapter/hex_object_database_resource.gd`

- `add_definition(definition)`
- `definition_for_id(object_id)`
- `has_definition(object_id)`
- `definition_ids()`
- `definitions_with_tag(tag)`

Definitions are `HexObjectDefinitionResource` resources with `id`, `display_name`, `scene`, `tags`, `default_properties`, and `preview_texture`.

### `HexLabelDatabaseResource`

Path: `res://addons/hex_map_kit/adapter/hex_label_database_resource.gd`

- `add_definition(definition)`
- `definition_for_id(label_id)`
- `has_definition(label_id)`
- `definition_ids()`
- `definitions_with_tag(tag)`

Definitions are `HexLabelDefinitionResource` resources with `label_id`, `display_name`, `default_text`, `style_key`, `tags`, and `metadata`.

## Validation

### `HexMapDocumentValidator`

Path: `res://addons/hex_map_kit/adapter/hex_map_document_validator.gd`

- `validate_document(document, options = {})`

Useful options:

- `tile_catalog`
- `tile_set`
- `object_database`
- `require_object_scenes`
- movement profile reachability options used by tests and validation dashboard paths

The result is `HexMapValidationResult`, which records `summary`, errors, warnings, rule ids, scopes, and optional cell/object metadata.

## Gameplay Runtime

### `HexMovementProfileResource`

Path: `res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd`

Fields:

- `profile_id`
- `default_passable`, `default_cost`
- `wall_passable`, `wall_cost`
- `terrain_costs`
- `blocker_keys`
- `blocker_tags`

Use it with `HexGrid`, `HexGameplayLayerData`, or `HexTileMapLayer` movement helpers.

### `HexGameplayLayerData`

Path: `res://addons/hex_map_kit/adapter/hex_gameplay_layer_data.gd`

- `from_map_data(data, movement_profile = null)`
- `from_document(document, movement_profile = null, tile_catalog = null)`
- `passable_cells()`
- `movement_costs()`
- `is_passable(hex)`
- `movement_cost(hex)`

It converts authoring data into passability/cost data for runtime path and range queries.

### `HexRuntimeQuerySample`

Path: `res://examples/basic_runtime/runtime_query_sample.gd`

- `query_document(document, start = null, goal = null, movement_budget = 4.0, movement_profile = null, tile_catalog = null)`
- `query_document_path(document_path, start = null, goal = null, movement_budget = 4.0, movement_profile = null, tile_catalog = null)`
- `export_runtime_objects(document, object_database = null)`

The sample returns dictionaries so it can be used in gameplay code, tests, or a minimal scene wrapper. Prefer `query_document()` when code already holds a `HexMapDocumentResource`; `query_document_path()` is a supplemental helper for loading a saved resource path.

## Examples

- `examples/basic_runtime/runtime_query_sample.gd`
- `examples/basic_runtime/runtime_query_example.tscn`
- `examples/editor_workflow/editor_workflow_example.tscn`
