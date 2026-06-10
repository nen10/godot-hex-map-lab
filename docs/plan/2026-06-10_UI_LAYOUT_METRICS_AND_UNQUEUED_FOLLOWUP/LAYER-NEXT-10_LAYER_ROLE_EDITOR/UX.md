# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep role rows read-only | low | medium | low | reject | It does not satisfy the role editing acceptance. |
| B. Add one selected-role editor beneath the role summary | high | low | medium | adopt | It gives a compact, scannable edit surface without replacing the role rows. |
| C. Make each role row a full table editor | medium | medium | high | reject | Godot label/tree table editing would be more intrusive than this slice needs. |
| D. Use typed controls for role properties | high | low | medium | adopt | CheckBox, SpinBox, and OptionButton match expected control semantics. |

## User Goal

The user should be able to select or target a Layer Stack role, edit its visibility, lock state, z-index, and writable source, then see the Layer Stack row and selected HexTileMap role layer reflect the change.

## Adopted UX

- Layers keeps the existing role summary and role rows.
- A dedicated Role Editor section shows the selected role and uses familiar typed controls:
  - visible and locked as checkboxes.
  - z-index as a spin box.
  - writable source as an option button.
- The editor shows a concise mounted state line that confirms the selected role, status, visibility, lock state, z-index, writable source, and target node.
- Missing roles can still be edited at the Layer Stack resource level; target reflection applies once the role node exists.

## Rejected / Deferred UX

- No Paint tab layer management duplication.
- No raw metadata editor or JSON field.
- No full resource path primary text.
- No sample-backed default stack selection.

## Experience Steps

1. User opens Layers and sees the current role relationship and role rows.
2. User selects or targets a role.
3. User toggles visible/locked, adjusts z-index, or changes writable source.
4. The visible role row and editor state update immediately.
5. If the selected HexTileMap has that role child layer, its visibility/z-index/editor metadata match the edited role.
