# PERF-61 Progress And Busy UI Implementation Plan

Date: 2026-06-08

## Target files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add a public progress snapshot that includes visibility, cancellability, and coarse busy step metadata.
2. Show validation/apply/finalize steps after threaded generation completes.
3. Show a delayed-operation status for orientation/tile-setting apply without changing the apply workflow.
4. Update headless editor tests for step text, ProgressBar visibility, cancel behavior, and lack of modal windows.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
