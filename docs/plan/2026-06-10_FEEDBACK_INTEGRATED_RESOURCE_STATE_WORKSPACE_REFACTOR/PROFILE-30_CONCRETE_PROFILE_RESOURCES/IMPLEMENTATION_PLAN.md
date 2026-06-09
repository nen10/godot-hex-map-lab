# PROFILE-30 Implementation Plan

## Scope

- Add concrete validation, generation, and export profile Resource classes.
- Wire Workspace asset context, resource factory, presets, and picker type metadata to those classes.
- Update tests and docs so profile slots are no longer generic Resource slots.

## Target Files

- `addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd`
- `addons/hex_map_kit/adapter/hex_generation_profile_resource.gd`
- `addons/hex_map_kit/adapter/hex_export_profile_resource.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_hex_adapter.gd`
- `docs/TEST.md`
- `docs/manual/MANUAL_WORKFLOW.md`

## Steps

1. Add concrete Resource classes and uid files.
2. Update asset context typing and setter casts.
3. Update factory creation/type names/type filter reasons.
4. Update Workspace preset creation and sync casts.
5. Update tests/docs for strict profile types.
6. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Validation Rule Suite picker is concrete.
- [x] Generation Profile picker is concrete.
- [x] Export Profile picker is concrete.
- [x] Created and duplicated profile assets use concrete classes.
- [x] Docs/manual explain each profile purpose.
- [x] Queue proof, self-review, and test result are updated.
