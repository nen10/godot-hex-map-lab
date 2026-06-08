# TAB-54 Policy

Task: `TAB-54_VALIDATE_TAB_ISSUE_NAVIGATOR`

Rules:

- Validate tab owns validation run state and issue navigation.
- Resource row Validate buttons remain absent; issue routes point users to owner tabs instead.
- Missing workspace asset issues must include target tab, component id, slot id, and suggested action.
- Document/catalog/cell issues should route to Catalog or Paint where possible, with focus target and fix suggestion visible.
- Sample assets must not be injected as validation fallback.
- CLEAN UI constraints remain active: no raw JSON or path-heavy issue display as the primary UI.

Completion evidence:

- `tests/test_editor_plugin.gd` verifies issue navigator fields, selection, routed tab navigation, and sample mode OFF.
- `docs/TEST.md` records the headless coverage.
- `./tools/test.sh` passes.
