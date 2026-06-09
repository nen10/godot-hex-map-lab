# PROFILE-31 Implementation Plan

## Scope

- Tighten document dependency validation for concrete profile resource kinds.
- Ensure workspace tab snapshots for Validate, QA, and Export expose concrete resource type/state.
- Make missing profile resources optional/missing rather than workspace validation blockers.
- Update tests and docs for profile dependency hydration and tab state.

## Target Files

- `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Add concrete profile dependency type checks.
2. Audit profile tab snapshots and add resource class/type/source state where missing.
3. Remove required-profile workspace issues that contradict optional/missing acceptance.
4. Extend existing headless tests for dependency hydration, concrete tab state, and missing optional state.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Concrete profiles hydrate from document dependencies.
- [x] QA / Validate / Export tabs show concrete profile resources.
- [x] Missing profiles are visible optional/missing state.
- [x] Generic profile Resource mismatch is validated.
- [x] Queue proof, self-review, and test result are updated.
