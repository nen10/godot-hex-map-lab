# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Preserve current visible Workspace while moving construction ownership | medium | low | medium | adopt | Users should see no regression while architecture gets safer for later screen redesign. |
| Redesign tab layouts during extraction | high later | high | high | reject | Visual redesign belongs to queued follow-up tasks after ownership is clear. |
| Hide weak screen panels until redesigned | low | high | low | reject | Removing visible task surfaces would weaken first impression and tests. |
| Add screen ownership metadata invisible to users | medium | low | low | adopt | It makes future UI metric and screen contract proof concrete without visual noise. |

## User Goal

The Workspace should keep acting like one coherent editor dock while each tab-specific screen owns the Control nodes that represent its task surface.

## Adopted Experience

- The Workspace still shows the same tabs and controls.
- Resources, Catalog, Layers, Validate, QA, Export, and Settings continue to expose the same visible task surfaces.
- Generate and Paint remain mounted as their existing dedicated components.
- No new visible debug text, raw path text, sample fallback, or placeholder action is introduced.

## Experience Steps

1. Open Hex Map Workspace.
2. Select a tab.
3. The tab content appears as before.
4. Internally, screen-specific panel construction is attributed to the corresponding screen script.
5. Workspace remains responsible for tab hosting, context wiring, refresh calls, and action dispatch.
