# UI Control Tree Parent-Child Dependencies

> Audit date: 2026-06-12
> Scope: `addons/hex_map_kit/editor/`, `tests/`

Code that accesses UI controls through the control tree (via index, parent, child iteration) rather than through direct member variable references. These are fragile under refactoring that changes parent-child relationships.

---

## Critical — Immediate break on parent change

### `hex_map_edit_tool.gd` — `_refresh_payload_controls_visibility()` (L3219)

**35 controls** toggled via `_set_control_row_visible()`. This function toggles **parent.visible**, not `control.visible`. Assumes every control is wrapped in a parent container (HBoxContainer row).

```gdscript
func _set_control_row_visible(control, visible: bool) -> void:
    var parent = (control as Control).get_parent()
    if parent is Control and parent != self:
        (parent as Control).visible = visible
```

**Controls affected:**
```
_tile_catalog_option    _tile_source_spin          _tile_atlas_x_spin
_tile_atlas_y_spin      _tile_alternative_spin     _default_floor_source_spin
_default_floor_atlas_x_spin  _default_floor_atlas_y_spin  _default_floor_alternative_spin
_default_wall_source_spin   _default_wall_atlas_x_spin   _default_wall_atlas_y_spin
_default_wall_alternative_spin  _overlay_item_key_edit    _overlay_item_key_option
_object_catalog_option  _object_id_edit             _object_definition_tree
_object_definition_scene_picker   _object_add_definition_button
_object_palette_status_label      _object_rotation_spin
_object_variant_edit    _object_variant_option      _object_property_editor
_object_properties_edit _object_properties_table    _object_spawn_condition_edit
_object_spawn_condition_option  _object_database_picker  _label_id_edit
_label_definition_tree  _label_text_edit            _label_database_picker
```

**Break scenario:** If any of these controls is moved out of its wrapper, or two controls share a parent row, visibility toggles affect the wrong node.

---

### `hex_map_edit_tool.gd` — `_control_row_is_visible()` (L3267)

Same pattern as above, but reads `parent.visible` instead of setting it. Used in:
- `paint_interaction_state_snapshot()` (5 call sites)
- `catalog_entry_view_state()` (~18 call sites via `normal_internal_controls_visible`)
- `_on_object_payload_changed()` (3 call sites)
- `authoring_field_source_snapshot()` (~10 call sites)

**Break scenario:** Snapshot state misreports UI visibility; edit callbacks fire incorrectly.

---

### `hex_map_edit_tool.gd` — `_control_effectively_visible()` (L3276)

Walks parent chain to check all-ancestors visibility. Used by:
- `_document_management_visible()`
- `_layer_stack_management_visible()`
- `_export_management_visible()`
- `_catalog_entry_management_visible()`

**Break scenario:** If an intermediate invisible container is added during refactoring, returns `false` unexpectedly.

---

### `hex_map_gen_dock.gd` — `_overlay_item_name_edit.get_parent()` (L4627)

In `_refresh_controls()`:
```gdscript
var item_name_row = _overlay_item_name_edit.get_parent()
if item_name_row is Control:
    item_name_row.visible = bool(control_state["overlay_item_name_row_visible"])
```

Same parent-wrapper assumption as `_set_control_row_visible`.

---

### `hex_map_gen_dock.gd` — `move_child()` by index (L2473)

```gdscript
container.move_child(row["row"], target)
```

Assumes query row container has no static children (labels, separators). If a static child is added, `target` index becomes misaligned with the `rows` array.

---

## Moderate — Scene-tree structural assumptions

### `_is_hex_tile_map_internal_layer` (DRY violation — 2 files)

| File | Line | Pattern |
|---|---|---|
| `hex_map_edit_tool.gd` | 3937 | `node.get_parent() is HexTileMapLayer` |
| `hex_map_workspace_binding_service.gd` | 623 | Same logic, duplicated |

Assumes internal TileMapLayer nodes (`_HexBase`, `_HexLoop`, `_HexOverlay`) are always direct children of `HexTileMapLayer`.

---

### `_editable_target_from_node` / `_tile_layer_target_from_node`

| File | Line |
|---|---|
| `hex_map_edit_tool.gd` | 3847 |
| `hex_map_gen_dock.gd` | 4490 |
| `hex_map_workspace_binding_service.gd` | 58 |

All call `get_parent()` on TileMapLayer nodes to find the owning HexTileMapLayer.

---

### `get_children()` + `queue_free()` rebuild patterns

| File | Line | Function |
|---|---|---|
| `hex_map_edit_tool.gd` | 2171 | `_refresh_object_property_editor()` |
| `hex_map_gen_dock.gd` | 1954 | `_refresh_source_registry_ui()` |

Assumes all children of the target container are transient and safe to `queue_free()`.

---

### `_visible_action_button_texts()` (L458)

`hex_map_editor_asset_slot_control.gd`:
```gdscript
for child in _actions_container.get_children():
    if child is Button and (child as Button).visible:
```
Assumes `_actions_container` contains only direct `Button` children. Nested sub-containers would hide buttons from detection.

---

## Low Risk — Diagnostic / test utilities

| File | Line | Pattern |
|---|---|---|
| `tests/test_editor_plugin.gd` | 9522 | `_control_row_visible()` mirrors fragile production pattern |
| `tests/test_hex_tile_map_layer.gd` | 529-552 | `get_child_count()` + `get_child(0)` index access |
| `tests/test_editor_plugin.gd` | 4192-4206 | `get_child_count()` exact assertions |
| `hex_map_edit_tool.gd` | 3961 | `_collect_target_layers_recursive` — stops at HexTileMapLayer boundary |
| `hex_map_gen_dock.gd` | 4464,4486,4585 | Recursive `get_children()` tree walks |
| `testing/hex_ui_layout_snapshot_collector.gd` | 34,94,98 | Intentional full-tree scan |
| Multiple files | — | `node.get_path()` for display/debug |


## Test Helper Reference

`tests/test_editor_plugin.gd` contains a mirror of the fragile `_control_row_is_visible`:

```gdscript
func _control_row_visible(control: Control) -> bool:     # L9522
    var parent = control.get_parent()
    if parent is Control:
        return (parent as Control).visible
    return control.visible
```

This helper implicitly validates the parent-wrapper convention. If controls are refactored to toggle their own `visible` directly, this test helper becomes incorrect.
