# DOC-70 UX

## Target User

Godot developer opening the repository docs to understand how to make and hand off a hex map with the addon.

## Desired Experience

- The first workflow reads as a game-dev authoring path, not a resource setup checklist.
- The user sees that Build is the graph-based generation surface, Paint is the design finishing surface, and Export is the Godot runtime handoff.
- Resources/Catalog/Layers are clearly support shelves for map semantics, not the main product route.

## Avoided Experience

- Starting with a long list of Resource types and tabs.
- Treating QA/Validate as the product's center.
- Treating bundled samples as production defaults.
- Presenting raw paths, raw tile ids, or debug text as the normal workflow.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Build -> Promote -> Paint -> Export | high | low | medium | adopt | Matches roadmap and product definition. |
| B. Resources -> Generate -> QA -> Validate -> Export | low | high | low | reject | Keeps old resource-first / parked-tab route. |
| C. Keep all details but add a short summary | medium | medium | low | reject | Old flow would still be the dominant manual path. |

## Experience Steps

1. Select or create a `HexTileMapLayer` context.
2. Build a generation graph and run `Generate`.
3. Promote generated terrain/overlay/object output into the Level Document through role-aware layers.
4. Paint manual fixes on document-owned layers without destroying generated layers.
5. Export a runtime handoff as data resource, scene, or graph resource.
6. Use Resources/Catalog/Layers when a step needs map semantics or missing project assets.
