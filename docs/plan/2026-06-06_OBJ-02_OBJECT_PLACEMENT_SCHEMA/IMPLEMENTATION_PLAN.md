# OBJ-02 Object Placement Schema Implementation Plan

作成日: 2026-06-07

## Scope

- Expand adapter entry conversion for `HexMapDocumentObjectPlacementResource` to include placement id, rotation, variant, spawn condition, layer id, runtime flag, metadata, and properties.
- Expand `HexMapDocumentAdapter.set_object()` and v2 replacement helpers to preserve full placement payloads.
- Keep legacy `document.objects` synchronized with enough fields for fallback display and compatibility.
- Add adapter tests for v2 typed placement roundtrip, adapter mutation, legacy rotation migration, and deleted-cell cleanup.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write test result and self-review, then update queue proof.

## Test Path

- `tests/test_hex_adapter.gd`
- `./tools/test.sh`

## Repair Policy

Missing placement fields, failed `.tres` roundtrip, or stale placements after deleted-cell cleanup are `repair-now`.
