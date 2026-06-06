# P0-01 Capability Matrix Implementation Plan

作成日: 2026-06-07
Queue task: `P0-01`

## Inputs

- `README.md`
- `docs/TEST.md`
- `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`
- `addons/hex_map_kit/core/`
- `addons/hex_map_kit/adapter/`
- `addons/hex_map_kit/editor/`
- `tests/`

## Outputs

- `docs/review/roadmap/CURRENT_CAPABILITY_MATRIX_2026-06-06.md`
- `docs/review/roadmap/RISK_REGISTER_2026-06-06.md`
- `docs/review/autopilot/P0-01_TEST_RESULT_2026-06-07.md`
- `docs/review/autopilot/P0-01_SELF_REVIEW_2026-06-07.md`
- Queue proof update in `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`

## Work Items

1. Read current source and test summaries for Generate / Edit / Runtime / Document / Test capability.
2. Classify plain `TileMapLayer` and `HexTileMapLayer` behavior.
3. Classify object / label / overlay schema state.
4. Write current capability matrix.
5. Write risk register with owner lane and next queue task.
6. Run `./tools/test.sh` and record the result.
7. Write self-review with `repair-now` classification.
8. Update queue status and proof.

## Test Path

No test file is added. Existing Test path evidence remains:

- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_core.gd`
- `tests/test_debug_scenes.gd`

Completion command:

```sh
./tools/test.sh
```
