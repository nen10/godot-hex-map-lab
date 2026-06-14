# ARCH-50 Implementation Plan

## Scope

- Add helper classes for map resource binding and document apply preparation.
- Update `HexTileMapLayer` to use helpers while coordinating display/payload application.
- Add tests for helper sources and coordinator responsibility snapshot.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.

## Target Files

- `addons/hex_map_kit/adapter/hex_tile_map_resource_binding.gd`
- `addons/hex_map_kit/adapter/hex_map_document_applier.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `tests/test_hex_tile_map_layer.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `ARCH-50` RUNNING and create plan docs.
- [x] Add resource binding and document applier helpers.
- [x] Update `HexTileMapLayer` apply paths to consume helper results.
- [x] Add tests for helper ownership and preserved runtime behavior.
- [x] Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `ARCH-50` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] `HexTileMapLayer` reports coordinator role.
- [x] Resource binding helper owns map resource preparation.
- [x] Document applier helper owns document apply preparation.
- [x] Existing runtime helper tests pass.
