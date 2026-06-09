# CLEAN-22 Policy

## Decisions

- The catalog screen is the normal place for TileSet, atlas, and PackedScene entry details.
- Brush controls must store and expose catalog keys as their normal contract.
- Missing or invalid catalog entries are validation information, not silent fallback behavior.
- Headless tests should assert user-facing catalog state and resource references; they should not require old numeric paint controls.

## Verification

- Tests should cover catalog entry rows, per-entry validation status, scene entry creation from `PackedScene`, and paint payload selection by catalog key.
- `./tools/test.sh` is the completion test path.
