# Policy

## Adopted Decisions

- Layers owns role property editing.
- Role editing is scoped to `visible`, `locked`, `z_index`, and `writable_source`.
- `locked` and `writable_source` remain layer entry metadata for this task.
- `visible` and `z_index` remain first-class entry fields and are mirrored to target child layers when available.
- Target node reflection must be visible in screen snapshots/tests, not only through internal state.

## Rejected Decisions

- Do not add a raw metadata/JSON editor.
- Do not make Paint own role editing.
- Do not silently select bundled sample Layer Stacks.
- Do not add analog tests.

## Resource / API / UI Boundary

- `HexMapLayersScreen` owns construction of role editor controls.
- `HexMapWorkspace` owns role editor snapshots, mounted refresh, and public role edit APIs.
- `HexMapEditTool` remains the source for sorted role rows and selected target resolution.
- `HexLayerStackResource` remains the Resource source of truth for role properties.
- `HexTileMapLayer` child layers receive reflected editor state when present.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Metadata fields for locked/writable | keep | Existing role rows already use metadata and no schema expansion is needed. | Future Resource schema task explicitly replaces it. | Layer editor tests assert row and target metadata. |
| Missing target role layer | allow resource-only edit | Users can configure a stack before creating child layers. | none | Tests edit before/after role node creation. |
| Sample stack defaults | reject | Completion must use project-created/duplicated resources. | none | Existing Layers test keeps sample mode off. |
| Paint mirror UI | reject | Layers owns role editing. | none | Paint ownership tests remain. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Layer Stack entry | Edited visible, locked, z-index, and writable source persist in the matching role entry. | Snapshot rows drift from resource data. | Role edit tests inspect `role_rows` and entry fields. |
| Target child layer | Existing role child layer mirrors visible and z-index and carries locked/writable metadata. | User sees different target state than the stack row. | Role edit tests inspect child layer properties/meta. |
| Mounted editor controls | Controls show current selected role values and not raw metadata. | UI remains summary-only or misleading. | Snapshot and mounted text/control tests. |
| Missing role node | Resource edit succeeds while target reflection reports missing. | Editor blocks legitimate stack authoring. | Tests edit before target child creation. |

## Completion Rule

`LAYER-NEXT-10` is complete only when Layers exposes a visible role editor, editing updates Layer Stack role properties, selected target role nodes reflect applicable properties, tests cover the edit path, and `./tools/test.sh` passes with UI metric P0 failures = 0.
