# TAB-53 Implementation Plan

Task: `TAB-53_LAYERS_TAB_ROLE_EDITOR`

Plan:

1. Mark `TAB-53` RUNNING and add `UX.md`, `POLICY.md`, and `IMPLEMENTATION_PLAN.md`.
2. Add a `layer_stack_role_panel` component before the Layers asset panel.
3. Enrich `layer_stack_screen_snapshot()` with selected HexTileMap relationship, required role list, role status counts, and action availability.
4. Refresh the role panel after Layer Stack asset, target, document, create/apply, and clear actions.
5. Extend editor tests to assert that Layers is now a role editor, not only a resource row.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`, repair any `repair-now` issues, write self-review/test result, update queue proof, and commit.

Acceptance mapping:

- Layer Stack resource visible: existing asset panel plus enriched snapshot.
- Target HexTileMap visible: relationship snapshot and role panel status.
- Roles visible: required role list and `role_rows`.
- Create/apply status visible: action availability snapshot and role status counts.
- Visibility/locked/writable visible: per-role row assertions.
