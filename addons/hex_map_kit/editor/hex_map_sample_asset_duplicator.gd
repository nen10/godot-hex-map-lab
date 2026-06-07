@tool
class_name HexMapSampleAssetDuplicator
extends RefCounted

const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")

const SAMPLE_CATALOG_PATH := "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres"
const SAMPLE_TILE_TEXTURE_PATH := "res://addons/hex_map_kit/assets/sample_hex_tiles.png"
const SAMPLE_OBJECT_SCENE_PATH := "res://addons/hex_map_kit/assets/sample_spawn_marker.tscn"


static func duplicate_sample_catalog_to_project(
	catalog_path: String,
	context: HexMapWorkspaceAssetContext = null
) -> Dictionary:
	var actual_catalog_path := _normalized_resource_path(catalog_path)
	if actual_catalog_path == "":
		return _result(false, ERR_INVALID_PARAMETER, actual_catalog_path)
	var base_dir := actual_catalog_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_dir))

	var texture_path := _join_resource_path(base_dir, "%s_tiles.png" % actual_catalog_path.get_file().get_basename())
	var scene_path := _join_resource_path(base_dir, "%s_spawn_marker.tscn" % actual_catalog_path.get_file().get_basename())
	var copy_texture_error := _copy_file(SAMPLE_TILE_TEXTURE_PATH, texture_path)
	if copy_texture_error != OK:
		return _result(false, copy_texture_error, actual_catalog_path, texture_path, scene_path)
	var copy_texture_import_error := _copy_texture_import_file(texture_path)
	if copy_texture_import_error != OK:
		return _result(false, copy_texture_import_error, actual_catalog_path, texture_path, scene_path)
	var copy_scene_error := _copy_file(SAMPLE_OBJECT_SCENE_PATH, scene_path)
	if copy_scene_error != OK:
		return _result(false, copy_scene_error, actual_catalog_path, texture_path, scene_path)

	var catalog := _duplicated_catalog(actual_catalog_path, texture_path, scene_path)
	if catalog == null:
		return _result(false, ERR_CANT_CREATE, actual_catalog_path, texture_path, scene_path)
	var save_error := ResourceSaver.save(catalog, actual_catalog_path)
	if save_error != OK:
		return _result(false, save_error, actual_catalog_path, texture_path, scene_path, catalog)
	catalog.resource_path = actual_catalog_path
	if context != null:
		context.set_tile_catalog(catalog)
	return _result(true, OK, actual_catalog_path, texture_path, scene_path, catalog)


static func default_catalog_file_name() -> String:
	return "sample_hex_tile_catalog_project_copy.tres"


static func duplicate_dialog_config() -> Dictionary:
	return {
		"file_mode": EditorFileDialog.FILE_MODE_SAVE_FILE,
		"filters": ["*.tres ; Godot resource"],
		"current_file": default_catalog_file_name(),
	}


static func _duplicated_catalog(catalog_path: String, texture_path: String, scene_path: String) -> HexTileCatalogResource:
	var sample_catalog = load(SAMPLE_CATALOG_PATH) as HexTileCatalogResource
	if sample_catalog == null:
		return null
	var catalog = sample_catalog.duplicate(true) as HexTileCatalogResource
	if catalog == null:
		return null
	catalog.catalog_id = _project_id_from_path(catalog_path)
	catalog.display_name = "Project Copy of Sample Hex Tile Catalog"
	catalog.resource_path = ""
	catalog.metadata = sample_catalog.metadata.duplicate(true)
	catalog.metadata["duplicated_from_sample"] = SAMPLE_CATALOG_PATH
	catalog.metadata["project_copy"] = true
	var scene = ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	catalog.tile_set = _project_tile_set(texture_path, scene)
	_rewrite_scene_entries(catalog, scene)
	return catalog


static func _project_tile_set(texture_path: String, scene: PackedScene) -> TileSet:
	var tile_set := TileSet.new()
	var texture := ResourceLoader.load(texture_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
	if texture != null:
		texture.resource_path = texture_path
		HexMapTileAdapter.configure_atlas_tile_set(
			tile_set,
			texture,
			true,
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			0,
			[Vector2i(0, 0), Vector2i(1, 0)]
		)
	if scene != null:
		var scene_source := TileSetScenesCollectionSource.new()
		scene_source.create_scene_tile(scene, 1)
		tile_set.add_source(scene_source, 1)
	return tile_set


static func _rewrite_scene_entries(catalog: HexTileCatalogResource, scene: PackedScene) -> void:
	if catalog == null:
		return
	for entry in catalog.entries:
		if entry == null:
			continue
		if String(entry.get("entry_type")) == "scene":
			entry.set("scene", scene)


static func _copy_file(source_path: String, target_path: String) -> int:
	var bytes := FileAccess.get_file_as_bytes(source_path)
	var read_error := FileAccess.get_open_error()
	if read_error != OK:
		return read_error
	var target = FileAccess.open(target_path, FileAccess.WRITE)
	var write_error := FileAccess.get_open_error()
	if write_error != OK:
		return write_error
	target.store_buffer(bytes)
	target.close()
	return OK


static func _copy_texture_import_file(target_texture_path: String) -> int:
	var source_import_path := "%s.import" % SAMPLE_TILE_TEXTURE_PATH
	if not FileAccess.file_exists(source_import_path):
		return OK
	var text := FileAccess.get_file_as_string(source_import_path)
	var read_error := FileAccess.get_open_error()
	if read_error != OK:
		return read_error
	text = text.replace(
		"source_file=\"%s\"" % SAMPLE_TILE_TEXTURE_PATH,
		"source_file=\"%s\"" % target_texture_path
	)
	var target = FileAccess.open("%s.import" % target_texture_path, FileAccess.WRITE)
	var write_error := FileAccess.get_open_error()
	if write_error != OK:
		return write_error
	target.store_string(text)
	target.close()
	return OK


static func _normalized_resource_path(path: String) -> String:
	var result := path.strip_edges()
	if result == "":
		return ""
	if result.get_extension().to_lower() != "tres":
		result = "%s.tres" % result.trim_suffix(".")
	return result


static func _join_resource_path(directory: String, filename: String) -> String:
	return "%s/%s" % [directory.trim_suffix("/"), filename]


static func _project_id_from_path(path: String) -> String:
	var base := path.get_file().get_basename()
	var result := ""
	for index in range(base.length()):
		var code := base.unicode_at(index)
		if (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122):
			result += char(code).to_lower()
		elif code == 45 or code == 95:
			result += char(code)
		else:
			result += "_"
	return "project_sample_catalog" if result == "" else result


static func _result(
	ok: bool,
	error: int,
	catalog_path: String,
	texture_path: String = "",
	scene_path: String = "",
	catalog: HexTileCatalogResource = null
) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"catalog_path": catalog_path,
		"texture_path": texture_path,
		"scene_path": scene_path,
		"catalog": catalog,
	}
