# Policy

## Adopted Decisions

- Existing screen scripts are the owner of screen-specific physical panel construction.
- `HexMapWorkspace` remains the tab host, shared context holder, dispatcher, signal connector, and refresh coordinator.
- Builder methods return the created Control references needed by Workspace; they do not own session mutation or cross-screen state.
- The extraction must preserve current component ids and tab asset slot contracts.

## Rejected Decisions

- Do not redesign Resources, Layers, Export, Catalog, QA, Validate, or Settings in this task.
- Do not introduce new legacy aliases, fallback text, raw JSON, visible path text, or numeric fallback controls.
- Do not make sample assets a production completion path.
- Do not add analog tests.

## Resource / API / UI Boundary

| area | owner | boundary |
|---|---|---|
| Tab creation and tab registry | Workspace | Creates pages and registers mounted components. |
| Screen-specific panel node creation | Screen scripts | Builds Controls for that screen's visible task surface. |
| Shared asset context | Workspace/session state | Screen builders receive data-free construction only; runtime context remains centralized. |
| Action signals | Workspace | Connects buttons/inputs to dispatcher or existing Workspace methods. |
| Refresh/render text | Workspace for this task | Text refresh stays in current methods to avoid mixing extraction with visual redesign. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Workspace mount wrappers | keep as thin host layer | Needed to assign fields, connect signals, and register components. | Later screen Control subclasses own refresh/action wiring. | Screen ownership tests verify construction moved to builders. |
| Existing screen snapshot methods | keep | They are behavior contracts and should not be rewritten during physical extraction. | Future screen redesign can move rendering state. | Existing `test_editor_plugin.gd`. |
| Existing component ids | keep | Tests and user-facing tab contracts depend on stable component ownership. | Only change through a future explicit screen contract task. | Component registry tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Workspace selected node/context | One selected HexTileMap and asset context source remains in Workspace/session. | Builders accidentally mutate state. | Builders only create nodes; Workspace keeps signal and refresh methods. |
| Tab component registry | Component ids and tab ownership stay stable. | Moving construction changes mount order or ids. | `test_editor_plugin.gd` tab/component contract. |
| UI metric gate | P0 failures stay zero. | Extraction creates missing scroll/control metadata. | `tests/test_workspace_layout_metric_gate.gd` through `./tools/test.sh`. |
| Screen ownership | Each extracted component names a screen script owner. | Metadata-only proof could drift from builders. | Screen scripts expose builder-owned component ids and Workspace reports them. |
