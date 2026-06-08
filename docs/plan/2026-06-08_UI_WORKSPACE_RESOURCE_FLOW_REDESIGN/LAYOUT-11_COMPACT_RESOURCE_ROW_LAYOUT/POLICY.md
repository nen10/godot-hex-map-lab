# LAYOUT-11 Policy

## Adopted Decisions

- Compact row presentation is an editor UX contract, not a data model change.
- Required type, selected path, source, status, and validation messages remain available through details and tooltips.
- The top-level visible row must remain short when a slot is missing.
- Tests should inspect a public layout snapshot rather than private node names.

## Rejected Decisions

- Do not remove action buttons in this task.
- Do not hide missing required resources.
- Do not replace typed resource pickers with generic Resource selectors.

## Resource / API / UI Boundary

- Resource/API state remains in `HexMapEditorAssetSlotState`.
- UI compaction lives in `HexMapEditorAssetSlotControl`.
- Workspace asset panels continue to mount the same slots.

## Task-Local Decisions

The details control starts collapsed. This keeps first impression compact while preserving diagnostic text for users who need it.
