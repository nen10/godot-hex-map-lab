# GQM-13 UX

## User Goal

Open Build, choose a graph template or project graph, generate the visible graph, and save/load graph assets without Profile/Simple/Batch header clutter.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Keep Profile/Simple as a secondary route | low | high | low | reject | It preserves the fallback mental model GQM-13 removes. |
| Template dropdown backed by graph asset library | high | medium | medium | adopt | Bundled and project graphs become one visible source list. |
| Save as/Load next to Template | high | medium | medium | adopt | Matches the Resource Model operation grammar. |
| Keep Context chips as text label | low | high | low | reject | It is label-heavy state text, not an operation. |

## Experience Steps

1. User opens the Build tab.
2. Header shows `Template`, `Save as...`, `Load...`, `Generate`, `Apply`, `Revert`, and status.
3. User chooses `基本形` or `Simple` from Template. If a graph already exists, replacement is confirmed before the canvas changes.
4. Generate always runs the graph currently visible on the canvas.
5. Save as stores the current graph in the project `graphs` layer; Load reads the selected bundled/project graph through the normalized graph load path.

## Removed UX

- Batch N / Seed randomize / Shape randomize.
- Profile row and Generate (Simple).
- Load Graph button and Overwrite selected checkbox.
- Context chip text label in the Build header.
