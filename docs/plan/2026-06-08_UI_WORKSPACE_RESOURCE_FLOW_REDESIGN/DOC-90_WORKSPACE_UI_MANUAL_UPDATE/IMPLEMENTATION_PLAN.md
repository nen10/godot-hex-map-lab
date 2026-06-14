# DOC-90 Workspace UI Manual Update Implementation Plan

Date: 2026-06-08

## Target files

- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `README.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Replace old `Document` tab startup guidance with the `Resources` tab and selected `HexTileMap` context.
2. Document auto resource sync, `Create Missing Resources`, shared resource selection, and unconfigured validation states.
3. Document `Generate` output target behavior for preview and applying to the selected Level Document.
4. Clarify sample learning and duplication language in manual and README.
5. Add manual coverage to `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
6. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
