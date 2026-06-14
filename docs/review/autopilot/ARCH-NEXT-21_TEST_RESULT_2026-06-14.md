# ARCH-NEXT-21 Test Result 2026-06-14

Task: `ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION`
Date: `2026-06-14`
Environment: macOS (local), Godot headless test runner

## Command

- `./tools/test.sh`

## Result

- **Status:** PASS
- **Exit code:** `0`
- **Observed warnings:** non-blocking `get_system_ca_certificates` platform warnings; no test failures.

## Evidence

- `test_hex_tile_map_layer.gd: all tests passed`
- `test_debug_scenes.gd: all tests passed`
- All other test files executed by `./tools/test.sh` reported `all tests passed`.

## Notes

- This includes parity and delegation assertions for:
  - `find_path`
  - `find_weighted_path`
  - `movement_range`
  - `is_map_connected`
  - `connected_component`
  - `connected_component_from_local`
- Runtime sample checks in `examples/basic_runtime/runtime_query_sample.gd` are also covered through `test_debug_scenes.gd` assertions.
