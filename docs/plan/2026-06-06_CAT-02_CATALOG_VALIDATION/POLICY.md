# CAT-02 Policy

## Decisions

1. Catalog validation returns `HexMapValidationResult` so later document/dashboard validation can compose catalog issues without a parallel result schema.
2. TileSet is passed directly to the helper; `tile_set_path` remains metadata until a future loader/UI task decides where catalog assets are resolved.
3. Atlas entries validate source existence, source type, atlas coordinate existence, and optional alternative tile when Godot exposes that query.
4. Scene entries validate `scene_path` through `ResourceLoader.exists()`. Source type validation is only applied when a TileSet is present.
5. Custom data extraction is a read helper, not a validation failure by itself. Missing custom data values return `null` rather than inventing defaults.

## Compatibility

- CAT-01 resource fields remain unchanged.
- Sample catalog loading remains valid even if a scene path is later reported missing by validation.
- Numeric fallback fields remain available for advanced/debug paths.

## Repair Criteria

- The helper must detect missing TileSet, missing source, invalid atlas coordinate, and missing scene path.
- Tests must prove tag/custom data extraction from a valid atlas tile.
- `./tools/test.sh` must pass.
