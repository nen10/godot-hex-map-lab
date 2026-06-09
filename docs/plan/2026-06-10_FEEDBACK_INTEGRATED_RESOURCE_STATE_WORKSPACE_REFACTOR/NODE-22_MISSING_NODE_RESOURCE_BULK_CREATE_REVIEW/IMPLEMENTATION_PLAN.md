# NODE-22 Implementation Plan

## Scope

- Keep missing resource creation limited to node-owned unique resources.
- Add post-create dependency sync from existing Workspace shared resources to the selected Level Document.
- Extend editor tests so node export, document dependency, and Workspace context match after creation.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Mark NODE-22 running and add plan files.
2. Add a Workspace helper that writes non-null shared context slots to selected document dependencies.
3. Call the helper after missing unique resources are created and save the updated Level Document.
4. Extend NODE-22 tests for dependency sync and no shared resource creation.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Bulk create remains node-owned only.
- [x] Shared resources are not created silently.
- [x] Existing shared Workspace resources are written to Level Document dependencies.
- [x] Node export, document dependency, and Workspace context match after creation.
- [x] Queue proof, self-review, and test result are updated.
