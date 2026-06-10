# Policy

## Adopted Decisions

- Paint owns painting feedback, not setup/resource management.
- Viewport affordance state comes from `HexMapPaintInteractionState`, last edit trace, and last hit/highlight state.
- The Paint screen snapshot must expose cursor, mode, target, selected cell, and last edit as structured rows.
- Mounted UI proof is required because this is a visible Paint tab task.

## Rejected Decisions

- Do not duplicate Resources, Catalog, or Layers management in Paint.
- Do not expose raw trace dictionaries or paths as primary text.
- Do not add analog tests.
- Do not change viewport edit semantics unless needed for feedback sync.

## Resource / API / UI Boundary

- `HexMapEditTool` remains the physical Paint tab component and owns mounted labels.
- `HexMapPaintInteractionState` remains the state source for paint readiness and view state.
- `HexMapWorkspace` exposes the Paint screen snapshot for workspace-level tests.
- `HexTileMapLayer` remains the visual highlight/display target.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Existing last-hit highlight | keep | It is the current viewport feedback behavior. | Future viewport renderer task replaces it. | Viewport edit test asserts highlight and Paint affordance sync. |
| Last edit detail string | keep | Existing tests and debug reports use it; new board summarizes it. | State reducer task can split richer event records. | Last edit tests plus affordance board tests. |
| Raw path/debug text | reject as primary UI | Paint first impression should be task feedback. | none | Snapshot tests assert path visibility false. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Brush/mode | Affordance board shows mode id/label, brush key, and readiness. | User cannot tell what the viewport will paint. | Paint snapshot tests. |
| Target layer | Board shows target name/class/ready state. | User edits the wrong layer silently. | Paint snapshot tests. |
| Cursor/selected cell | Board shows selected/visual cell after viewport input. | Viewport edit is invisible in Paint tab. | Workspace viewport edit test. |
| Last edit | Board shows document/target/display outcome and payload. | User cannot tell whether an edit applied. | Workspace viewport edit test. |

## Completion Rule

`PAINT-NEXT-10` is complete only when Paint exposes a structured affordance board and mounted text, viewport edits update the workspace Paint snapshot for cursor/selected cell/target/mode/last edit, tests cover the sync path, and `./tools/test.sh` passes with UI metric P0 failures = 0.
