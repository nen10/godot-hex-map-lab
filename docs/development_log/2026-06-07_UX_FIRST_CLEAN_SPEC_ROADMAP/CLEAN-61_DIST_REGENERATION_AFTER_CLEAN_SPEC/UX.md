# CLEAN-61 Dist Regeneration After Clean Spec UX

## Goal

Regenerate the addon distribution artifacts from the current clean-spec addon tree.

## User Contract

- `tools/package_addon.sh` creates current `dist/hex_map_kit-0.3.0.zip`.
- `dist/hex_map_kit-0.3.0.manifest.txt` matches the current addon-only tree.
- The manifest contains no development-only roots.
- The manifest contains no legacy or migration docs.
- Public release upload is not performed.

## Non-Goals

- Do not publish the zip.
- Do not include source-repository docs, tests, examples, or debug scenes in the addon zip.
