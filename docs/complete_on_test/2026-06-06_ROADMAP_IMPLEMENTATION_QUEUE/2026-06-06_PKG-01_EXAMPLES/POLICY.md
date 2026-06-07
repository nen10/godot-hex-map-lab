# PKG-01 Policy

Task: `PKG-01`  
Created: 2026-06-07  
Status: RUNNING

## Decisions

- Public examples must avoid `addons/hex_map_kit/editor/*` preloads so they can load in exported/runtime projects.
- `examples/basic_runtime/` focuses on loading a saved v2 document path and asking movement queries.
- `examples/editor_workflow/` focuses on the authoring handoff: construct a v2 document with terrain, overlay, object, label, catalog path metadata, and layer stack expectations.
- Example scenes/scripts should be small and headless-testable rather than polished demo art.
- Resource path checks belong in `tests/test_debug_scenes.gd` because it already covers runtime helper/sample loading.

## Compatibility

- No saved schema changes.
- No editor dock behavior changes.
- Existing `runtime_query_sample.gd` API remains compatible.

