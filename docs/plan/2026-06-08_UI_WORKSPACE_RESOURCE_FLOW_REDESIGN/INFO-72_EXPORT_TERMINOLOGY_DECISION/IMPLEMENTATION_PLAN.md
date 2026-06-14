# INFO-72 Export Terminology Decision Implementation Plan

Date: 2026-06-08

## Target files

- `docs/review/roadmap/EXPORT_TERMINOLOGY_DECISION_2026-06-08.md`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/manual/MANUAL_EDITOR_PLUGIN.md`
- `docs/manual/MANUAL_WORKFLOW.md`
- `docs/manual/MANUAL_PACKAGE.md`
- `README.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`

## Steps

1. Record the terminology decision table for Save Document, Runtime Handoff, Data Export, Package Build, and Debug Report.
2. Make Export tab visible output-mode state match the decision.
3. Update manual/README wording to use Runtime Handoff for the editor Export workflow.
4. Add focused headless coverage for visible Export output terms.
5. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
