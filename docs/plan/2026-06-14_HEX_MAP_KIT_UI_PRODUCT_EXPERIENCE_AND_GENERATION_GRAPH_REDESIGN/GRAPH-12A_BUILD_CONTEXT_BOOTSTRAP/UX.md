# GRAPH-12A Build Context Bootstrap UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---:|---|---|
| A. Missing-resource warning only | low | high | low | reject | The user still cannot run or promote from Build. |
| B. Create project files before running | medium | medium | medium | reject | Build's first action becomes file management instead of graph work. |
| C. Create embedded graph/document context for selected graph-less layer | high | low | medium | adopt | The user can start Build from an unconfigured project node without samples or path text. |
| D. Create a new HexTileMapLayer when none is selected | high | medium | medium | adopt | Matches the §10 default owner model: one selected node owns the graph context. |

## Experience Steps

1. User opens Build with no selected HexTileMapLayer or with a selected HexTileMapLayer that has no graph/document context.
2. Build exposes an explicit context action instead of silently relying on Resources.
3. Activating the action creates an embedded `HexGenerationGraphResource` and a Level Document context.
4. If no HexTileMapLayer is selected, a new `HexTileMapLayer` is created and selected.
5. The Build canvas restores the embedded graph, selects the graph output node, and can Generate.
6. Promote writes to the selected node's Level Document; existing selected-node tracking remains the only owner.

## First Impression

Build remains graph-first. The user sees the canvas and a context strip that can report whether Build context is ready. The repair does not make Resource rows the primary surface.
