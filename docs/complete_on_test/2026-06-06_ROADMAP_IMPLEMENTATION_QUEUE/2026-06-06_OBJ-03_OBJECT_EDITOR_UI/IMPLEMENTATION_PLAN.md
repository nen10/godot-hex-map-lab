# OBJ-03 Object Editor UI Implementation Plan

作成日: 2026-06-07

## Scope

- Extend Hex Map Edit object payload state with rotation, variant, and spawn condition.
- Add matching UI controls and visibility handling.
- Ensure Object mode edits route the full typed placement payload into documents and `HexTileMapLayer` edit state.
- Add headless editor tests for visibility, v2 typed placement save, and Undo/Redo restoration of property state.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write test result and self-review, then update queue proof.

## Test Path

- `tests/test_editor_plugin.gd`
- `./tools/test.sh`

## Repair Policy

Missing typed placement fields, broken old `set_object_payload()` calls, or failed Undo/Redo restoration are `repair-now`.
