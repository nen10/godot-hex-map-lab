@tool
class_name HexAdjacencyRuleEditor
extends Window

const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")

var _initial_rules_text := "default=0.0"
var _apply_callback: Callable
var _cancel_callback: Callable
var _rules_edit: LineEdit
var _rules_status_label: Label


func _init(
	initial_rules_text: String = "default=0.0",
	apply_callback: Callable = Callable(),
	cancel_callback: Callable = Callable()
) -> void:
	_initial_rules_text = initial_rules_text
	_apply_callback = apply_callback
	_cancel_callback = cancel_callback


func _ready() -> void:
	title = "Adjacency Rule Set"
	min_size = Vector2i(520, 120)
	close_requested.connect(_on_cancel_pressed)

	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	_rules_edit = LineEdit.new()
	_rules_edit.text = _initial_rules_text
	_rules_edit.placeholder_text = "default=0.2;1=0.8;2,1=0.4"
	_rules_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rules_edit.text_changed.connect(_on_rules_text_changed)
	root.add_child(_wrap_labeled("Rules", _rules_edit))

	_rules_status_label = Label.new()
	_rules_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rules_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(_rules_status_label)
	_refresh_rules_status()

	var button_row = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(button_row)

	var apply_button = Button.new()
	apply_button.text = "Apply"
	apply_button.pressed.connect(_on_apply_pressed)
	button_row.add_child(apply_button)

	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_on_cancel_pressed)
	button_row.add_child(cancel_button)


func _wrap_labeled(label_text: String, control: Control) -> Control:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _on_apply_pressed() -> void:
	if _apply_callback.is_valid():
		_apply_callback.call(_rules_edit.text)
	queue_free()


func _on_cancel_pressed() -> void:
	if _cancel_callback.is_valid():
		_cancel_callback.call()
	queue_free()


func _on_rules_text_changed(_text: String) -> void:
	_refresh_rules_status()


func _refresh_rules_status() -> void:
	if _rules_status_label == null:
		return
	var report = HexAdjacencyRuleSet.parse_rules_text_report(_rules_edit.text, 0.0)
	_rules_status_label.text = _adjacency_rule_status_text(report)


func _adjacency_rule_status_text(report: Dictionary) -> String:
	var rules: Dictionary = report.get("rules", {})
	var invalid_entries: Array = report.get("invalid_entries", [])
	var text = "Rules: %d" % rules.size()
	if bool(report.get("used_fallback", false)):
		text += " (fallback default)"
	if not invalid_entries.is_empty():
		text += "  Invalid: %s" % ", ".join(invalid_entries)
	return text
