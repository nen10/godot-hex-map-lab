# CLEAN-33 Delete Harmful UI Paths UX

## Goal

Remove or demote UI paths that expose implementation leftovers as normal authoring workflow.

## User Contract

- Normal UI has no editable path text.
- Normal UI has no numeric fallback tile controls.
- Manual `TileMapLayer` apply is not a primary Generate action.
- `v2`, migration, and legacy vocabulary do not appear in normal UI.
- Any remaining debug/advanced controls have a documented reason.

## Non-Goals

- Runtime helper APIs may still use internal numeric tile state where needed.
- CLEAN-40 owns the larger manual rewrite after the screen model settles.
