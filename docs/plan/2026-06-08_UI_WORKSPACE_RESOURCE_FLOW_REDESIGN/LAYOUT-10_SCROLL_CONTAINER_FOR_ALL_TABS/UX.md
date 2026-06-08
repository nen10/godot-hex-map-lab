# LAYOUT-10 UX

## User Goal

Keep every workspace tab usable when the Godot dock is narrow, short, or placed in a constrained editor layout. A developer must be able to reach the primary controls by scrolling instead of losing the lower part of a tab.

## Operation Steps

1. Open the Hex Map Workspace dock.
2. Switch among Document, Generate, Paint, Catalog, Layers, Validate, QA, Export, and Settings.
3. Resize or dock the panel in a constrained area.
4. Scroll each tab to reach the bottom controls.
5. Switch tabs without losing the registered tab/component contract.

## Adopted UX

- Each workspace tab root owns a `ScrollContainer` or equivalent.
- Tab content remains a vertical workflow layout inside the scroll root.
- Horizontal scrolling is disabled; controls should adapt vertically.
- Focus-follow scrolling is enabled so keyboard or picker focus can reveal controls.

## Retained UX

- Current component ownership remains unchanged.
- Generate and Paint keep their embedded tools.
- Existing tab names remain unchanged until `TAB-50`.

## Deferred UX

- Compact resource row layout is deferred to `LAYOUT-11`.
- Resource button cleanup is deferred to `ASSET-31` / `ASSET-32`.
- Document-to-Resources rename is deferred to `TAB-50`.

## Existing UX Interference

Generate and Paint already contain internal scroll areas. This task still adds a workspace tab scroll root so the workspace-owned panels and future tab content share one contract.
