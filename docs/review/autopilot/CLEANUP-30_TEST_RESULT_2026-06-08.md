# CLEANUP-30 Test Result

Task: `CLEANUP-30` Debug numeric fallback quarantine  
Queue: `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Result

PASS

## Command

```sh
./tools/test.sh
```

## Coverage Notes

- Verified debug numeric tile fallback is OFF by default in Settings/session state.
- Verified Settings can explicitly enable and disable debug numeric tile fallback.
- Verified normal plain `TileMapLayer` document apply does not fill missing catalog assignments through numeric source/atlas fallback.
- Verified explicit debug opt-in restores numeric fallback source/atlas behavior.
- Verified missing catalog assignment remains a document validation issue.
- Verified legacy plain-target numeric rendering tests now opt into debug fallback intentionally.
- Verified package manifest and the full Godot headless suite.

## Warnings

- The existing macOS CA certificate warning appeared during Godot runs.
- Existing warning-path checks still emit expected Godot warnings.
