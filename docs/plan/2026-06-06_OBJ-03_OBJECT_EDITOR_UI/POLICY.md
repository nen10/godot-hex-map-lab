# OBJ-03 Object Editor UI Policy

作成日: 2026-06-07

## Decisions

- Reuse the existing Object mode row instead of creating a new editor subsystem.
- Treat the current JSON properties line as the headless-testable property editor for this task.
- Add compact placement controls for rotation, variant, and spawn condition.
- Keep `set_object_payload()` source-compatible by adding optional parameters.
- Continue to use `HexMapDocumentAdapter.set_object()` so plain document editing and `HexTileMapLayer` wrapper editing share one schema path.

## Compatibility

Existing tests and user scripts that call `set_object_payload(object_id, properties)` keep working. Empty object id still removes the placement at the clicked cell.

## Non-goals

- Dedicated multi-row property table widgets can be improved later if needed, but are not required for typed placement save/undo coverage.
- Object layer instancing is `OBJ-04`.
