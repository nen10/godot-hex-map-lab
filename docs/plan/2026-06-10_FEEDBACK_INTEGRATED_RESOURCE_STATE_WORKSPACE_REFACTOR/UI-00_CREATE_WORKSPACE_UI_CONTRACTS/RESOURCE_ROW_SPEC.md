# Resource Row Spec

## Purpose

Resource rows let users select, create, validate, or explicitly learn from project resources without turning filepath/debug state into the first impression.

## Layout Contract

Preferred layout:

```text
wide dock:
  [Role label] [Resource picker expands] [Status icon/short state] [Actions]

narrow dock:
  line 1: [Role label] [Status icon/short state]
  line 2: [Resource picker expands] [Actions]
```

The row must have stable dimensions. Status changes, hover text, or action visibility must not resize the row enough to shift surrounding controls unpredictably.

## Visible Content

Always visible:

- role label, such as `Level Document` or `Tile Catalog`,
- picker/select control,
- compact status icon or short state,
- real actions, such as `Create New` or explicit sample learning action.

Tooltip/detail:

- resource path,
- required type and type-filter reason,
- source badge explanation,
- validation messages,
- blocked/disabled reason,
- resource purpose text when too long for the row.

Debug report only:

- raw state snapshot,
- raw JSON,
- node path,
- internal ids,
- fallback/debug flags.

## Status Contract

Status must be derived from `HexMapEditorAssetSlotState.view_state()`.

Required status kinds:

- `ok`
- `missing`
- `optional`
- `invalid`
- `warning`
- `sample`

The visible row may temporarily use short text, but UI-01 should prefer icon+tooltip. Long status prose belongs in tooltip/detail.

## Action Contract

Allowed visible actions:

- create a project resource,
- apply an explicitly visible bundled sample learning source,
- open a real picker/dialog,
- clear a selected resource when the row owns that action.

Disallowed visible actions:

- placeholder Details button,
- no-op Open/Select/Validate/Link/Node/Sample buttons,
- actions that only write a temporary label without changing state.

## Path Policy

Filepaths are never the primary visible row label. They may appear in:

- picker tooltip,
- row detail surface if the user asks for details,
- debug report,
- copy/debug flow.

## Sample Policy

Bundled samples may appear only as explicit learning sources. A row that applies a sample must make the sample source visible and must not count as production completion proof unless the active task is sample/package integrity.
