# NODE-23 Implementation Plan

## Steps

1. Add Workspace write-back state/readback for selected-node auto-link readiness.
2. Connect Workspace asset context slot changes to selected-node write-back.
3. Apply node-owned slots:
   - Level Document -> `HexTileMapLayer.level_document_resource`
   - Layer Stack -> `HexTileMapLayer.layer_stack_resource`
4. Preserve shared slots in Workspace context only.
5. Surface node/workspace relationship status in selected-node snapshots.
6. Update editor tests for direct selection, create/open paths, shared resource behavior, and blocked states.
7. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
8. Run `./tools/test.sh`.
9. Write self-review and queue proof.

## Acceptance Mapping

- Document slot selection writes to selected node: tested through Workspace context/slot assignment.
- Catalog / Layer Stack / Object DB / Label DB policy behavior: tested by node vs shared context assertions.
- Node/workspace diff visible: snapshot exposes per-slot relationship rows and blocked reasons.
- Auto-link failures explain why: snapshot reports no selected node or auto-link disabled.
