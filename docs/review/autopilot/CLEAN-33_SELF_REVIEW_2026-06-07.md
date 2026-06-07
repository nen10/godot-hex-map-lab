# CLEAN-33 Self Review

Date: 2026-06-07
Task: CLEAN-33 Delete redundant / harmful UI paths

## Acceptance

- Generate Dock numeric floor/wall tile controls remain internal but are hidden from normal UI.
- Overlay item-pool numeric tile controls and copy buttons remain internal but are hidden from normal UI.
- Generate Dock manual apply is hidden and demoted from `Apply Layer` primary wording to `Advanced Apply`.
- Edit Dock target atlas path text is read-only status text.
- Manual and test docs no longer present numeric fallback or manual Apply Layer as normal workflow.

## Verification

- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- `git diff --check` PASS.

## Review Notes

- Backend numeric state remains because existing adapter/display tests still exercise explicit tile mapping. This is treated as internal/debug state, not normal UX.
- No `v2` or migration wording was introduced.
- `repair-now`: none.

## Residual Risk

- Full deletion of internal numeric state would require deeper adapter/test redesign and is not needed for the CLEAN-33 normal UI acceptance.
