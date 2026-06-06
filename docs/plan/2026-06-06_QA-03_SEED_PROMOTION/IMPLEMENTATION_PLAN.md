# QA-03 Implementation Plan

## Inputs

- Queue item: `QA-03`
- Dependencies: `QA-02`, `LD2-05`
- Target files:
  - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `tests/test_editor_plugin.gd`
  - `docs/TEST.md`

## Steps

1. Add promoted document state and helpers to `HexMapGenDock`.
2. Ensure generated document snapshots include v2 terrain layer data.
3. Store full in-memory batch snapshot per score row and sanitized generation snapshot in metadata.
4. Implement seed and batch-row promotion helpers.
5. Add editor plugin tests for v2 document creation, metadata, and saved resource roundtrip.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`, repair any `repair-now` findings, then write self-review and queue proof.

## Acceptance

- A chosen seed creates a v2 document.
- The document includes generation snapshot metadata.
- Tests cover promotion from batch row and saved resource roundtrip.
- `./tools/test.sh` passes or records an allowed environment block.
