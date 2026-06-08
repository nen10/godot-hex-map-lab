# TAB-52 Policy

Task: `TAB-52_CATALOG_TAB_DETAIL_EDITOR`

## Decisions

- Catalog entry meaning is the primary UI: display name, key, type, tags, status, and preview explanation.
- `source_id` and `atlas_coords` are metadata. They may exist in snapshots and tooltips, but they are not the primary inputs.
- Preview absence is a visible state with a reason, not an empty string.
- Catalog creation still requires arbitrary project assets and must not silently rely on bundled samples.

## Completion Bar

- Catalog screen snapshot exposes entry rows and selected/default entry detail.
- Tests cover atlas, scene, placeholder/missing-preview states.
- Tests assert raw source/atlas controls are not primary.
- `./tools/test.sh` passes.
