# RES-11 Implementation Plan

## Scope

- Add source/source-badge metadata to workspace asset context and slot snapshots.
- Hydrate shared dependencies from selected Level Document into workspace context.
- Preserve manual project overrides.
- Add editor test coverage and docs/test proof.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Extend context and slot state with `document_dependency` source and `Document Dependency` badge.
2. Pass context source metadata through asset panel sync.
3. Add workspace hydration method backed by `HexMapDocumentDependencyService`.
4. Trigger hydration on Level Document selection and expose a snapshot for tests.
5. Add focused editor tests for hydration, missing dependencies, and manual override.
6. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Document selection hydrates shared dependencies.
- [x] Hydrated rows show `Document Dependency`.
- [x] Missing dependencies remain missing.
- [x] Manual override is preserved.
- [x] Queue proof, self-review, and test result are updated.
