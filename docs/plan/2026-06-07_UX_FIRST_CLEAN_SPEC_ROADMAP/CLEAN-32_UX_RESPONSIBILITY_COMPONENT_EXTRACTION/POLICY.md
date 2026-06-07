# CLEAN-32 Policy

## Decisions

- Introduce `HexMapWorkspace` as the one dock-level owner selected by CLEAN-31.
- Introduce `HexMapWorkspaceComponentRegistry` as the source of truth for tab-to-responsibility mapping.
- Keep `HexMapGenDock` and `HexMapEditTool` as interim mounted components so existing behavior is not lost while responsibility extraction proceeds.
- Component names and tests are based on UX responsibility, not class size.

## Verification

- Headless tests assert workspace tabs, component responsibility mapping, session forwarding, plugin registration, and viewport input routing.
- Existing direct Generate/Edit tests continue to cover the mounted interim components.
