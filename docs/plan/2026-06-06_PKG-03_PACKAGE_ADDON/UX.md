# PKG-03 Package Addon UX

Task: `PKG-03`  
Created: 2026-06-07  
Status: RUNNING

## Goal

Let maintainers build a reproducible addon-only package and validate that the package manifest excludes development-only files before any public upload.

## Operation Steps

1. Run `./tools/package_addon.sh --check` during tests to validate the package file list.
2. Run `./tools/package_addon.sh` to create `dist/hex_map_kit-<version>.zip` and a manifest when preparing a release artifact.
3. Read the migration guide before moving a v0.2 project to the v0.3 package surface.
4. Perform any public release upload only after a human release check.

## Non-goals

- No public release upload.
- No Godot Asset Library submission.
- No dev-repo zip; this task packages only `addons/hex_map_kit/`.

