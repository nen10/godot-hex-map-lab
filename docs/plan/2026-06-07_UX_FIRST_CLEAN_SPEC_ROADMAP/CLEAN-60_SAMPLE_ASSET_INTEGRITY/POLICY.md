# CLEAN-60 Policy

## Decisions

- Keep sample resources under `addons/hex_map_kit/assets/` so addon-only packaging includes them.
- Enforce package sample dependencies in `tools/package_addon.sh --check`, not only by broad tree walking.
- Test the sample catalog as a loadable Resource, a validator-clean catalog, and a package-contained scene/texture reference.

## Verification

- `tests/test_hex_adapter.gd` checks sample catalog paths and validator result.
- `tools/package_addon.sh --check` requires sample catalog, atlas, and scene dependency.
- `./tools/test.sh` remains the completion test path.
