# TAB-53 UX

Task: `TAB-53_LAYERS_TAB_ROLE_EDITOR`

The Layers tab is the place to understand how a selected HexTileMap node is split into child role layers. It must show the active Layer Stack resource, the target HexTileMap node, and each stack role's current node/status without forcing the user to infer everything from a ResourcePicker row.

Primary screen:

1. Show the selected target HexTileMap state near the top of the Layers tab.
2. Show the Layer Stack resource relationship to the selected node.
3. List role rows for terrain, overlay, object, debug, collision, and navigation, including visibility, locked, writable, and missing/ok state.
4. Keep Layer Stack resource create/open/save controls available below the role editor.
5. Surface Create Missing Layers and Apply Document as available actions only when their prerequisites are understandable from the panel state.

Empty states:

- No selected HexTileMap: show that the user must select a HexTileMap node before layer role actions can target anything.
- No Layer Stack: show that a Layer Stack resource is needed before role rows describe the project stack.
- Missing child layers: show missing rows and keep Create Missing Layers as the repair action.

Non-goals:

- Do not make Layers another generic asset list.
- Do not add sample templates as silent defaults.
- Do not expose raw path text or JSON as the normal explanation of stack state.
