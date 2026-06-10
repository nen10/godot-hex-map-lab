# UI-00 Self Review 2026-06-10

## Scope

- Created Workspace visible contract documents:
  - `WORKSPACE_SCREEN_CONTRACT.md`
  - `WORKSPACE_STATE_MACHINE.md`
  - `VISIBLE_CONTROL_INVENTORY.md`
  - `RESOURCE_ROW_SPEC.md`
  - `DEBUG_LABEL_POLICY.md`
- Created UI-00 task plan files.
- Updated `docs/TEST.md` with UI-00 coverage.
- Updated queue status, proof, and dependency sweep.

## Acceptance Review

- Each tab now has a documented split between always-visible information, tooltip/detail content, and debug-report-only content.
- Debug, filepath, node path, raw JSON, numeric fallback, and internal state are documented as non-normal UI.
- Generate has an explicit caution block: later UI-03 cleanup must preserve working parameter, progress, preview, and apply/status controls.
- Resource row compact/adaptive contract is documented for UI-01.
- No code/UI implementation was added in UI-00; UI-01/UI-02/UI-03 own those changes.
- No new analog test was created.

## Repair-Now Review

- No repair-now items remain.

## Follow-Up

- `UI-01`, `UI-02`, and `UI-03` are now READY because `UI-00` is complete.
- `UI-01` is the next queue task in roadmap order.
