# NODE-22 UX

## User Goal

Users can create the missing node-owned resources for a selected `HexTileMapLayer` without accidentally creating shared project assets or splitting Workspace state from Level Document dependencies.

## Operation Steps

1. Select a `HexTileMapLayer`.
2. Review missing unique resources in `Resources`.
3. Choose a project save directory and keep or edit the safe resource prefix.
4. Press `Create Missing Resources`.
5. Workspace creates only the missing Level Document and/or Layer Stack, writes them to the selected node, and carries already selected shared project resources into the Level Document dependency list.

## Adopted UX

- The bulk action is for node-owned unique resources only.
- Shared project resources remain explicit resource picker / create flows.
- If shared resources were already selected, the new Level Document records them as dependencies so subsequent hydration is consistent.

## Rejected UX

- No silent Tile Catalog / Object DB / Label DB / Movement Profile creation in this bulk flow.
- No node export expansion for shared project resources.
