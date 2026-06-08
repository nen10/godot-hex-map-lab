# NODE-24 Implementation Plan

## Scope

- Add Generate output target controls and snapshot API.
- Preserve current preview auto-apply behavior.
- Add explicit apply-to-selected-document action.
- Attach generated metadata to the committed document and update workspace/session relationship state.
- Cover the behavior in editor plugin tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/review/autopilot/NODE-24_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/NODE-24_TEST_RESULT_2026-06-08.md`

## Steps

1. Add output target constants, control state, and status label to Generate.
2. Capture the latest generation snapshot and expose output target status via `output_target_snapshot()`.
3. Implement `apply_current_generation_to_selected_document()`.
4. Copy generated document state into the selected node's Level Document and synchronize workspace/session context.
5. Attach metadata that identifies Generate output target and selected node relationship.
6. Add headless editor coverage for preview vs committed document, Resources relationship update, and blocked apply.
7. Run `./tools/test.sh`, self-review, update queue proof, and commit.

## Completion Checklist

- Generate tab exposes `Output target`.
- Preview only and Apply to selected Document are distinct.
- Apply updates selected node Level Document and workspace relationship.
- No selected node blocks apply with a visible reason.
- No `repair-now` items remain after self-review.
