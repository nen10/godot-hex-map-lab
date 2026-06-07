# CLEAN-11 Test Result 2026-06-07

Task: `CLEAN-11_ADAPTER_COMPATIBILITY_REMOVAL`

## Commands

- `./tools/test.sh`

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

Observed expected environment warnings:

- macOS `get_system_ca_certificates` warning from Godot startup.
- Existing editor warning-path tests for invalid adjacency rules, missing source registry resource, empty placement mask, empty deductor floor source, and missing overlay source registry data.

## Coverage Notes

- `tests/test_hex_adapter.gd` verifies catalog-aware tile/overlay/document adapters resolve catalog keys and skip missing keys instead of using numeric fallback.
- `tests/test_hex_adapter.gd` verifies `document.tile_assignment_missing` validation for missing catalog assignments.
- `tests/test_editor_plugin.gd` verifies missing assignment appears through the validation dashboard/debug report, while compatibility warning output is absent.
- `tests/test_hex_tile_map_layer.gd` verifies plain `TileMapLayer` document apply uses catalog-clean entries.
