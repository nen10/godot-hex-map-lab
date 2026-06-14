# ARCH-NEXT-20 Test Result 2026-06-14

Command:

```sh
./tools/test.sh
```

Result: PASS

Artifacts:

- Package manifest: `.godot_user/package-check/20260614-112438-99926/hex_map_kit-0.3.0.manifest.txt`
- Package zip: `.godot_user/package-check/20260614-112438-99926/hex_map_kit-0.3.0.zip`

Tests:

- `test_hex_core.gd`
- `test_hex_map_generation.gd`
- `test_hex_adapter.gd`
- `test_hex_tile_map_layer.gd`
- `test_workspace_state_transitions.gd`
- `test_asset_slot_state.gd`
- `test_generation_run_state.gd`
- `test_paint_interaction_state.gd`
- `test_workspace_screen_contracts.gd`
- `test_workspace_layout_metrics.gd`
- `test_workspace_layout_metric_evaluator.gd`
- `test_workspace_layout_metric_gate.gd`
- `test_editor_plugin.gd`
- `test_debug_scenes.gd`

Notes:

- macOS CA certificate warnings are non-fatal and pre-existing in this environment.
- `test_editor_plugin.gd` emits expected warnings for negative-path conditions in some sample and source validation scenarios.
