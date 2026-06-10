# UI-00 UX

## User Goal

A user opening the Workspace should understand each tab's job, the next productive action, and whether required project resources are ready without reading filepath text, debug state, raw JSON, or placeholder buttons.

## Operation Steps

1. Select a HexTileMap node.
2. Open Workspace and scan the current tab.
3. Read the tab purpose and readiness summary.
4. Pick or create project Resources from compact rows.
5. Use tooltips for type, source, path, and validation detail.
6. Use debug report / copy flow only when diagnosing state.
7. Move to task tabs: Generate, Paint, Catalog, Layers, Validate, QA, Export, Settings.

## Adopted UX

- Each tab has an explicit purpose and visible next action.
- Always-visible UI uses short role names, state labels/icons, and primary commands.
- Tooltip/detail surfaces hold resource type, source badge explanation, path, and longer validation or blocked-reason text.
- Debug report holds root state, ViewState, raw snapshot, internal ids, node paths, and raw payloads.
- Resource rows use a compact/adaptive model: role label, picker, compact status, and real actions only.
- Generate keeps its working controls visible until UI-03 repairs dead area/status from the state model.

## Maintained UX

- Project asset selection remains first-class in Resources/Catalog/Layers/Validate/QA/Export.
- Sample learning remains opt-in and separate in Settings.
- FileDialog flows remain callback/config based.
- Existing state snapshots remain available for tests and debug report generation.

## Retired Or Deferred UX

- Visible debug/path/internal state as normal UI is retired.
- Details button as a placeholder is retired; detail belongs in tooltip, a real drawer, or debug report.
- Row-level no-op buttons remain disallowed.
- Generate visual restructuring is deferred to `UI-03`.
- Settings boolean label cleanup is deferred to `UI-02`.

## Existing UX Interference

- Resource rows still expose short status text such as `OK`, `Missing`, and `Optional`; UI-01 will move that toward icon+tooltip while preserving state meaning.
- Settings still has debug-oriented labels; UI-02 owns the visible simplification.
- Generate has the most delicate existing control surface; UI-03 must avoid hiding active parameter/progress/preview controls merely to reduce empty space.
