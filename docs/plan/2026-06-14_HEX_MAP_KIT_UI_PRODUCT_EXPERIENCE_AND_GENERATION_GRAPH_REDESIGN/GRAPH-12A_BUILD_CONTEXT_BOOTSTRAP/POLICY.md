# GRAPH-12A Policy

## Adopted Decisions

- Build may create an embedded, unsaved graph/document context for an unconfigured HexTileMapLayer.
- If no HexTileMapLayer is selected, Build may create a new `HexTileMapLayer` node and select it.
- The selected HexTileMapLayer remains the context owner; Build must not create a second independent context owner.
- Embedded graph semantics are copy/embed, not project-path reference.
- Full graph resource persistence remains under `GRAPH-14_GRAPH_RESOURCE`.

## Rejected Decisions

- Do not use bundled sample assets as hidden defaults.
- Do not require project save paths before Build can run.
- Do not expose raw graph JSON or path text as the user-facing solution.
- Do not implement overwrite/merge load UX in this repair task.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Embedded graph handle before full GRAPH-14 resource lifecycle | allow | The UI needs a graph owner now; full save/load is already queued. | `GRAPH-14` replaces/extends the handle with canonical persistence. | Build bootstrap tests assert embed semantics and no path dependency. |
| Existing missing-resource Resources flow | keep | It remains useful for explicit project asset file creation. | none | Existing NODE-22 tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| no selected HexTileMapLayer | Build creates one node and selects it | hidden owner | snapshot records `created_layer: true` and selected node |
| selected graph-less HexTileMapLayer | selected node receives graph and document context | Resource reference remains missing | test asserts graph resource, document resource, workspace context, and Promote succeed |
| selected node already has graph/document | existing refs are preserved | accidental overwrite | test asserts no replacement |
| Build canvas | restored graph is the visible work surface | label-only completion | headless snapshot + Build screen contract |
