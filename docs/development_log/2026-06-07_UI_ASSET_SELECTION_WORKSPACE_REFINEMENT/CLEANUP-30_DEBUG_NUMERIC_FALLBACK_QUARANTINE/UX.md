# CLEANUP-30 UX

## Intent

Keep normal project-asset application honest: missing catalog selection must remain visible instead of being hidden by numeric tile source/atlas fallback.

## User Model

- Normal Paint / Catalog flows use catalog keys and project Tile Catalog resources.
- If the catalog is missing, the UI reports a missing asset or empty apply rather than silently using numeric source ids.
- Numeric source/atlas settings are available only as an explicit debug escape hatch from Settings.
- Debug fallback is OFF by default and is not feature completion proof.

## Non-Goals

- Do not remove HexTileMapLayer display tile settings used by runtime/debug scenes.
- Do not add analog tests during CLEAN UI work.
