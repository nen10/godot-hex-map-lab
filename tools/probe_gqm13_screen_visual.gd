extends SceneTree

const HexMapBuildScreen = preload("res://addons/hex_map_kit/editor/hex_map_build_screen.gd")


func _init() -> void:
	_run.call_deferred()


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	await process_frame
	var img := get_root().get_texture().get_image()
	var dir := "res://.godot_user/visual-verification/GQM-13-18"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	img.save_png("%s/%s.png" % [dir, name])
	print("saved %s/%s.png" % [dir, name])


func _run() -> void:
	get_root().size = Vector2i(1560, 1000)
	var screen = HexMapBuildScreen.new()
	get_root().add_child(screen)
	await process_frame
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.size = Vector2(1560, 1000)
	await process_frame

	var applied = screen.apply_template_by_name("基本形", {"confirm": false, "force": true})
	print("template applied ok=%s" % str(applied.get("ok", applied)))
	await process_frame
	var report = screen.run_graph()
	print("generate ok=%s" % str(report.get("ok", false)))
	screen.graph_canvas().select_graph_node("items")
	await _capture("swept_header_basic_template")
	quit()
