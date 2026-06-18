# RESCTX-42 Design Review

Target: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS/`
Main class: editor UI / UX
Decision: `pass_with_followups`

## Inputs

- Task packet files
- `docs/review/autopilot/RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS_SELF_REVIEW_2026-06-15.md`
- Current code: resources screen, workspace Build/Paint context chips
- Current design dependency: `DESIGN-11_TAB_IA_AND_PRIORITY/TAB_IA.md`
- Current tests: `tests/test_editor_workspace.gd`, `tests/test_editor_paint.gd`, `tests/test_build_screen_full.gd`

## Review

| item | result | evidence |
|---|---|---|
| Goal / inputs / deliverables | pass | Packet implements Resources shelf and work-tab context chips. |
| Adopt / reject / defer decisions | pass | Readiness/next-action label rows are removed; `Create missing` becomes a CTA. |
| Test gate vs product proof gate | pass | Tests cover shelf groups, context chips, missing resources, and non-duplication of Map chip. |
| Fixed points vs control surface | pass | Fixed point is Resources as asset shelf; controls are resource group cards and create-missing action. |
| Implementation confirmation | partial | RESCTX task intentionally excludes global top strip, but removes per-tab Map duplication on the assumption that DESIGN-11 owns it. Current code has no live top strip. |

Proof grade: `editor_projection_verified`

## Follow-Up

Implementation shortage is recorded as `DRF-001` in `DESIGN_REVIEW_FEEDBACK.md`: global Map/workflow context has no implemented owner after per-tab Map chips were removed.
