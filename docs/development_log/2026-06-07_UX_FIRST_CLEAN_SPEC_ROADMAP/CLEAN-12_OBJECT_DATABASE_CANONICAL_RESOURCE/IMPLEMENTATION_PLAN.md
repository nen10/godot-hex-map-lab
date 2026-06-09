# CLEAN-12 Implementation Plan

## Steps

1. Remove `version`, legacy `objects`, migration sync, and legacy lookup from `HexObjectDatabaseResource`.
2. Replace object definition `scene_path` with `scene: PackedScene`.
3. Replace `preview` / `preview_path` with `preview_texture: Texture2D`.
4. Update object layer direct instance resolution to use `PackedScene` resources.
5. Update document validation to detect null object scene resources.
6. Update runtime export to return `scene` resources instead of `scene_path`.
7. Rewrite object database, validation, runtime export, docs, and test overview coverage.
8. Run `./tools/test.sh`, self-review, repair `repair-now` findings, update queue, and commit.

## Test Path

- `./tools/test.sh`
