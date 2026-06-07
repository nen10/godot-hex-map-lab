# WORKSPACE-11 UX

## User Goal

The workspace exposes stable tab/component identity so tests and later UI code can reason about task surfaces without depending on private child node names.

## Operation Steps

1. Workspace tabs mount their task components.
2. Code can ask a tab which component ids it exposes.
3. Code can ask a tab which asset slot ids it owns.
4. Tests assert the registry contract rather than implementation details.

## Adopted UX

- Component ids describe user-facing responsibilities, such as `catalog_asset_panel` and `validation_issue_navigator`.
- Asset slot ids remain Resource/API identifiers, such as `tile_catalog` and `generation_profile`.
- The registry describes mounted components and is not a visual placeholder.

## Deferred UX

- Rich component metadata for screen-specific editors remains in later SCREEN tasks.
