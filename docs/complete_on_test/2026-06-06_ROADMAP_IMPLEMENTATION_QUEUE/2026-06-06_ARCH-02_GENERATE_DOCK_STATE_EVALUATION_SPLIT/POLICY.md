# ARCH-02 Policy

Task: `ARCH-02`  
Created: 2026-06-07  
Status: COMPLETE

## Decisions

- Extract pure state evaluation into a new editor helper script instead of moving UI nodes.
- Keep `HexMapGenDock` as the owner of node construction and node mutation.
- The evaluator should not depend on live Godot controls.
- The evaluator may receive simple booleans, counts, and mode ids from the dock.
- Existing private dock tests may continue to inspect controls while new tests cover the pure evaluator directly.

## Compatibility

- No saved resource changes.
- No public editor workflow changes.
- Existing Generate Dock tests must continue to pass.
