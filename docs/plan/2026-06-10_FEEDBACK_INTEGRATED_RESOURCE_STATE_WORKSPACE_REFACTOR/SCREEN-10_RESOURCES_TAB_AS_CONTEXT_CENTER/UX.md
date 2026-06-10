# SCREEN-10 UX

## User Goal

Resources should be the first place a developer understands which HexTileMap is selected, what authoring document/resources it uses, what is missing, where each resource came from, and what to do next.

## Operation Steps

1. Select or clear a HexTileMap node.
2. Open Resources.
3. Read the selected map summary and readiness status.
4. Scan required/shared/optional resource groups.
5. Inspect source badges without reading file paths.
6. Use the missing-resource next action when node-owned resources are absent.
7. Use resource rows for create/select/save details.

## Adopted UX

- Selected node name/status is visible; node path is tooltip/debug detail.
- Resource group status is summarized with counts and missing labels.
- Source badges are screen-level rows, not only row-level hidden detail.
- Missing unique resources have visible action state and next-action copy.

## Deferred UX

- Catalog entry editing remains in `SCREEN-20`.
- Layer role/editor relocation remains in `SCREEN-21`.
- Manual workflow docs remain in `DOC-90`.
