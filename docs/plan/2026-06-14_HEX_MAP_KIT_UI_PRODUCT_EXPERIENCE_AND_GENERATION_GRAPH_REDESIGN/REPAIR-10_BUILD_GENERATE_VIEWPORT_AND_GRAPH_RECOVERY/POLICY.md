# REPAIR-10 Policy

## Source Of Truth

- Product baseline: `docs/design/PRODUCT_DEFINITION.md`
- Generation graph baseline: `docs/design/GENERATION_GRAPH_MODEL.md`
- Handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
- Design system reference: `docs/policy/design-system.md`

## Non-Negotiable Rules

- Build graph remains the backbone.
- Samples are not production proof.
- UI first impression is completion evidence.
- `Generate` completion proof must be viewport projection, not thumbnail/cache existence.
- No new generation engine.
- No new Resource schema for this repair.
- No new analog tests.
- Do not reopen completed roadmap tasks; create this repair task and schedule follow-ups.

## Apply/Revert Rule

Generated results are preview-pending until the user presses `Apply`.

- `Apply` clears the revert snapshot and marks the preview kept.
- `Revert` restores terrain/overlay/object document state from before projection and reapplies the viewport display.
- `Apply` is prohibited if viewport projection failed.

## Projection Success Rule

`viewport_preview_visible` may be true only when all are true:

- preview state is `preview_pending` or `applied`,
- active layer exists and is inside the scene tree,
- `ensure_display_tiles()` succeeded,
- layer display status has tile sources,
- layer apply report is successful,
- `display_used_cell_count() > 0`.

## Follow-Up Separation

The following are important but outside this repair:

- multi-overlay Result resource contract,
- intermediate output child node model,
- graph-wide state evaluator,
- Region Filter item-key/dropdown UX,
- edge deletion interaction,
- exact Markov Mesh / adjacency rules parity with old Generate.

They must not be used as reasons to call REPAIR-10 complete, and they must not be silently assumed complete by REPAIR-10 tests.
