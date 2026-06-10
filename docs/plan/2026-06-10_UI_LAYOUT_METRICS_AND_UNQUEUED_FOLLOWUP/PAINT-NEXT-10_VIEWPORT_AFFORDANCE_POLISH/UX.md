# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep one compact Paint Workspace line | low | medium | low | reject | It hides viewport feedback details in one dense string. |
| B. Add a concise affordance board | high | low | medium | adopt | Cursor, mode, target, selected cell, and last edit become scannable. |
| C. Add setup ResourcePicker rows to Paint | low | high | medium | reject | Paint should point to setup owners, not duplicate them. |
| D. Add new viewport input controls | low | medium | medium | reject | Existing viewport input works; the missing piece is visible feedback. |

## User Goal

The user should be able to paint in the viewport and immediately see the Paint tab confirm the active brush cursor, selected cell, target layer, mode, and last edit result.

## Adopted UX

- Paint keeps setup ownership delegated to Resources, Catalog, and Layers.
- Paint exposes an affordance board with five rows: Cursor, Mode, Target, Selected Cell, Last Edit.
- The mounted affordance text updates after mode/brush/target changes and after viewport edits.
- The board avoids raw resource paths and raw trace dictionaries as primary UI.

## Rejected / Deferred UX

- No ResourcePicker setup rows in Paint.
- No raw JSON/debug trace primary text.
- No new viewport command semantics.
- No analog tests.

## Experience Steps

1. User selects a target and brush/mode.
2. User paints through the viewport.
3. Paint tab shows the cursor/selected cell and active mode/target.
4. Last edit feedback confirms document, target, display, and payload outcome.
5. Setup issues continue to point to their owning tabs instead of showing duplicated controls.
