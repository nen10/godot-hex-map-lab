# TAB-53 Policy

Task: `TAB-53_LAYERS_TAB_ROLE_EDITOR`

Rules:

- The Layers tab owns layer-role understanding. It may reuse edit-tool operations, but visible screen state must not depend on being in the Paint tab.
- The active Layer Stack is a node-owned resource when a selected HexTileMap is present.
- Role rows must show user-facing state: role, child node name, visible, locked, writable, and missing/ok.
- The selected HexTileMap and Layer Stack relationship must be explicit: linked, missing stack, missing node, or mismatch.
- Project Layer Stack assets remain the production path. Sample templates may be duplicated to a project asset, but samples must not become silent execution fallback.
- CLEAN UI constraints remain active: no raw fallback wording, no numeric fallback UI, and no new analog tests.

Completion evidence:

- `tests/test_editor_plugin.gd` verifies Layers tab component ownership, relationship snapshot, required roles, and role row state.
- `docs/TEST.md` records the headless coverage.
- `./tools/test.sh` passes.
