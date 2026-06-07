# PKG-01 Implementation Plan

Task: `PKG-01`  
Created: 2026-06-07  
Status: RUNNING

## Acceptance

Examples load without editor-only errors; test/debug scene checks resource paths.

## Steps

1. Add a basic runtime example scene/script that wraps `runtime_query_sample.gd`.
2. Add `examples/editor_workflow/` with README and a runtime-safe sample v2 authoring document builder.
3. Extend `tests/test_debug_scenes.gd` to load/check example scenes/scripts and exercise the editor workflow sample.
4. Update `docs/TEST.md`.
5. Run targeted debug scene test and `./tools/test.sh`.
6. Write PKG-01 test result and self-review docs.
7. Update queue proof and dependency sweep.

## Repair Classification

- `repair-now`: any example preload path fails, any example uses editor-only scripts, or `./tools/test.sh` fails due to PKG-01.
- `follow-up-ready`: broader API docs/manual split or addon package zip work.
- `manual-optional`: open the example scene in Godot editor for visual inspection.

