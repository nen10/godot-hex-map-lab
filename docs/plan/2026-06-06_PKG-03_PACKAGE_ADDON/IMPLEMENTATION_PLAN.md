# PKG-03 Implementation Plan

Task: `PKG-03`  
Created: 2026-06-07  
Status: RUNNING

## Acceptance

Addon-only zip can be built; manifest excludes dev-only files; migration guide v0.2 -> v0.3 exists. Human check only before public release upload.

## Steps

1. Update addon package metadata to v0.3.
2. Add `tools/package_addon.sh` with normal package mode and `--check` mode.
3. Wire package manifest check into `tools/test.sh`.
4. Add package and migration guide docs.
5. Update README and `docs/TEST.md`.
6. Run `./tools/package_addon.sh --check`, `./tools/package_addon.sh`, and `./tools/test.sh`.
7. Write PKG-03 test result and self-review docs.
8. Update queue proof and dependency sweep.

## Repair Classification

- `repair-now`: package includes dev-only files, required addon files are missing, zip cannot be built, migration guide is missing, or `./tools/test.sh` fails.
- `follow-up-ready`: public upload or asset library submission.
- `manual-optional`: inspect the generated `dist/` zip contents before public upload.

