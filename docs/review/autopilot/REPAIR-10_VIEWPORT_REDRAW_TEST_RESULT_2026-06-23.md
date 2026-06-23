# REPAIR-10 viewport redraw follow-up test result

Date: 2026-06-23
Branch: `autopilot/ui`

## Focused tests

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/test_editor_layer_after_redraw_fix.log --path . --script res://tests/test_editor_layer.gd
```

Result: pass.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/test_generation_promote_after_redraw_fix_2.log --path . --script res://tests/test_generation_promote.gd
```

Result: pass.

## Visual probe

```sh
/Applications/Godot.app/Contents/MacOS/Godot --log-file .godot_user/probe-logs/probe_gui_after_redraw_fix_2.log --path . --script res://tools/build_generate_viewport_probe.gd
```

Result: pass.

Artifact:

```text
.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/2026-06-23_132155/build_generate_viewport_probe.json
.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/2026-06-23_132155/build_generate_viewport_probe.png
```

Probe highlights:

- `viewport_projection_ok`: `true`
- `viewport_preview_visible`: `true`
- `preview_commit_state`: `preview_pending`
- `selected_layer_display_used_cell_count`: `24`
- `raster_capture.status`: `saved`
- `raster_capture.non_background_samples`: `4160`

## Standard test suite

```sh
TEST_JOBS=4 ./tools/test.sh
```

Result: pass.

Known non-fatal macOS certificate warnings appeared during Godot startup.
