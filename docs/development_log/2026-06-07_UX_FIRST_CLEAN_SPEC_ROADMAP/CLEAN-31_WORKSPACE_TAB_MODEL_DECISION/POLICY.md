# CLEAN-31 Policy

## Decisions

- The architecture decision must compare 2-dock, workspace dock, and main screen options explicitly.
- The decision must cite UX criteria: document-centered workflow, screen discoverability, Godot editor compatibility, and narrow-width behavior.
- The selected model becomes the information architecture for CLEAN-32 component extraction and later manual updates.
- "Large file" or "large class" is not a decision criterion.

## Verification

- Verification is docs-focused: decision document exists, queue proof references it, and `./tools/test.sh` still passes.
