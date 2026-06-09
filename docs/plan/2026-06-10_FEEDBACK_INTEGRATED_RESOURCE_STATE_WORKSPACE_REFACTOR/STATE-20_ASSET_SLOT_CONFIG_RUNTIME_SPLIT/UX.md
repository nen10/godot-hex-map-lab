# STATE-20 UX

## User Goal

When a workspace asset row shows a resource status, the row should be based on one explicit state model: what the slot requires, what is currently selected, whether that selection validates, whether a sample is available, and what happened in the last operation.

## Operation Steps

1. Workspace defines an asset slot such as Level Document, Tile Catalog, or optional profile.
2. The slot state captures immutable config separately from current selection.
3. Validation evaluates selected resource type, required/missing state, and sample source warning.
4. Operations such as create, sample duplicate, select, and clear update operation result without changing slot definition.
5. Row UI consumes ViewState fields for status label, status icon kind, tooltip, disabled state, and action availability.

## Adopted UX

- Use ViewState fields for row status instead of rebuilding status text from private fields.
- Keep existing row layout and actions for this task.
- Represent OK / Missing / Optional / Warning / Error as structured status fields that UI-01 can later render as icon + tooltip.

## Deferred UX

- Compact one-line row layout, adaptive narrow layout, and icon-only visible status are deferred to `UI-01`.
- New detail surfaces are deferred unless a later task gives them a real purpose.
