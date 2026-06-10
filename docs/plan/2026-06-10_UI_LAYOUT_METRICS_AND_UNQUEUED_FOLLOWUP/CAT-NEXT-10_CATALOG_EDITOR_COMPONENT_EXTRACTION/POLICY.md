# Policy

## Adopted Decisions

- Catalog entry list/detail/create/validate behavior is owned by a dedicated Catalog editor component.
- `HexMapWorkspace` remains the screen host, asset-slot owner, session/context synchronizer, and refresh coordinator.
- `HexMapEditTool` may consume catalog row/status formatting for brush selectors, but normal catalog management ownership stays with Catalog.
- Existing visible Catalog behavior and project-asset selection requirements must remain intact.

## Rejected Decisions

- Do not turn sample assets into the Catalog completion path.
- Do not expose raw JSON, path dumps, fallback wording, numeric fallback controls, or debug-only owner text in the UI.
- Do not redesign rich previews in this task.
- Do not add analog tests.

## Resource / API / UI Boundary

| area | owner | boundary |
|---|---|---|
| Tile Catalog asset slot | Workspace / asset panel | Creation, open/save/clear, context sync, and slot source tracking. |
| Catalog entry list/detail/preview state | Catalog editor component | Pure catalog-entry data and validation mapping. |
| Catalog create/validate actions | Catalog editor component | Mutates the selected catalog resource and returns action/validation results. |
| Catalog screen snapshot | Workspace | Assembles screen contract, slot state, component ownership, and component-provided entry state. |
| Paint brush catalog consumption | EditTool | Uses selected catalog keys and tile configs for brush payloads only. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| EditTool catalog row helpers | delegate to component | Paint still has legacy selector UI, but should not own normal catalog semantics. | Future Paint redesign removes non-primary management controls. | Paint brush/catalog selector tests. |
| Textual preview dictionaries | keep | Rich previews are queued separately and current tests assert textual preview state. | `CAT-NEXT-11` implements tile/scene preview UI. | Catalog screen tests and component owner tests. |
| Workspace wrapper methods | keep thin | Existing tests and public editor hooks call Workspace action helpers. | Future Catalog Control subclass owns action routing. | Workspace Catalog action tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Workspace asset context | Selected Tile Catalog remains the source for Catalog actions. | Component bypasses context sync. | Workspace methods call component then sync/refresh. |
| Catalog entries | Atlas/scene/placeholder detail semantics remain unchanged. | Extraction changes preview/status data shape. | Existing Catalog screen assertions. |
| Paint brush state | Paint consumes catalog keys but does not own entry management. | Delegation removes selector behavior. | Paint catalog selector tests and snapshot ownership flags. |
| UI metric gate | P0 failures stay zero. | Added ownership proof creates visible debug leakage. | `./tools/test.sh` UI metric report. |
| Component ownership | Entry list/detail/create/validate have a dedicated Catalog owner row. | Metadata drifts from actual component. | New owner row assertions in `tests/test_editor_plugin.gd`. |
