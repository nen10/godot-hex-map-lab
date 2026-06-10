# PROC-90 Policy

## Adopted Decisions

- Regenerate `dist` only in this final roadmap process task.
- Commit regenerated manifest and zip when they differ from the current committed artifacts.
- Record the diff result in self-review.
- Keep `tools/test.sh` behavior unchanged.

## Rejected Decisions

- Do not add committed `dist` freshness to normal test gates.
- Do not publish or upload the package.
- Do not include source repository docs/tests/debug/tools/examples in the addon zip.

## Resource / API / UI Boundary

- `tools/package_addon.sh` packages only `addons/hex_map_kit/`.
- Source docs and test files are repository material, not addon zip contents.
- Sample assets remain included in the addon zip as learning assets.

## Compatibility

Package contents follow the current addon tree and `addons/hex_map_kit/plugin.cfg` version.
