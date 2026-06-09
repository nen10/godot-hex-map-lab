# SCREEN-22 UX

## User Goal

A project author manages a Layer Stack as a project asset from the Layers tab, picks a scene root to find the target `HexTileMapLayer`, previews role state, and applies or clears roles without relying on a bundled sample template.

## Operation Steps

1. Open the Workspace `Layers` tab.
2. Create or select a project `HexLayerStackResource`.
3. Optionally duplicate an authoring/runtime template into a project `.tres` asset.
4. Pick a target scene root so editable `HexTileMapLayer` candidates come from the current scene.
5. Review role rows: terrain / overlay / object / debug / collision / navigation.
6. Create missing role layers, apply the current document to the role layers, or clear a selected role.

## Adopted UX

- The Layer Stack asset slot is the main entry point for project asset selection.
- Built-in layer templates are presets that become project assets only through an explicit duplicate/save action.
- Target selection starts from a scene root and resolves real scene nodes, not a sample scene.
- Missing target or missing document is a visible screen state, not a hidden fallback.

## Deferred UX

- Rich role editing for per-role lock, z-index, and custom writable source remains screen presentation work after this action/state contract is in place.
- Analog/manual visual verification remains deferred during CLEAN UI work.

## Removed UX

- Treating a built-in or sample template as production completion without a project asset copy.
- Using a target scene sample as the normal Layer Stack proof path.
