# LST-01 Implementation Plan

## Scope

Add layer stack resource/schema and templates, extend `tests/test_hex_tile_map_layer.gd` and `docs/TEST.md`, run `./tools/test.sh`, self-review, queue proof, and commit.

## Steps

1. Add `hex_layer_stack_entry_resource.gd`.
2. Add `hex_layer_stack_resource.gd` with role constants, lookup helpers, and standard/minimal templates.
3. Extend `tests/test_hex_tile_map_layer.gd` with template role/name checks and save/load roundtrip.
4. Update `docs/TEST.md` test overview.
5. Run `./tools/test.sh`; repair failures in-task.
6. Write `docs/review/autopilot/LST-01_SELF_REVIEW_2026-06-07.md`, update queue proof, and commit.
