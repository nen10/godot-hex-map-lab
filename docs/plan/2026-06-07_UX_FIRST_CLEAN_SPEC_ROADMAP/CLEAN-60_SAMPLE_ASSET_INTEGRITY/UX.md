# CLEAN-60 Sample Asset Integrity UX

## Goal

Make the packaged sample catalog safe for first-run use after clean Resource references.

## User Contract

- The sample catalog references only package-contained resources.
- The sample scene tile uses a packaged `PackedScene`.
- The sample atlas uses a packaged texture.
- The sample catalog has no debug path references.
- Package manifest checks fail if sample dependencies are missing.
- `HexTileCatalogValidator.validate_catalog(sample)` is clean.

## Non-Goals

- CLEAN-61 owns dist regeneration.
- Public release upload remains manual.
