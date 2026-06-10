# UI-01 Policy

## Adopted Decisions

- `HexMapEditorAssetSlotState.view_state()` remains the row source of truth.
- Visible status is a compact swatch/icon affordance with tooltip; status prose is not visible row text.
- Row layout uses a stable adaptive two-line structure.
- Filepath, source, type, validation detail, and purpose stay in tooltip/detail/debug surfaces.
- Placeholder Details button remains absent.

## Rejected Decisions

- Do not add sample defaults or sample-only completion proof.
- Do not expose resource paths as primary labels.
- Do not reintroduce Select/Open/Validate/Clear no-op row buttons.
- Do not redesign tab-level workflows in this task.

## Boundaries

- `HexMapEditorAssetSlotControl` owns row presentation.
- `HexMapEditorAssetSlotState` owns status/source/action ViewState.
- `HexMapWorkspaceAssetPanel` should continue mounting rows without knowing layout internals.
- Tests should assert layout snapshot and ViewState, not private child order.
