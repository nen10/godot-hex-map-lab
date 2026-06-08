# PERF-62 Incremental Update And Debounce Implementation Plan

Date: 2026-06-08

## Target files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add a debounced tile-settings apply scheduler with pending/token state and a public snapshot.
2. Route orientation, tile setting, and catalog selection callbacks through the scheduler.
3. Keep `_apply_tile_settings_to_current_layer()` as the synchronous execution path used by the scheduled apply.
4. Update editor tests to verify repeated changes coalesce into one apply and progress stays consistent.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
