# Policy

## Adopted Decisions

- The redesign is additive visual state over existing screen components, not a new resource schema.
- Resources remains the owner of selected node, Level Document, and shared dependency readiness.
- Layers remains the owner of Layer Stack relationship, role rows, and role actions.
- Export remains the owner of runtime handoff readiness, destination, and result state.
- Asset selection remains typed ResourcePicker-based and sample-free unless explicit sample learning mode is used.

## Rejected Decisions

- Do not duplicate Resources/Layers/Export management in Paint.
- Do not expose full resource paths as primary visible labels.
- Do not add package build/upload UI in this task.
- Do not add analog tests.

## Resource / API / UI Boundary

- Screen component scripts own panel construction.
- `HexMapWorkspace` owns screen snapshots and mounted label refresh.
- `HexMapWorkspaceAssetPanel` remains responsible for typed asset selection.
- `HexMapEditTool` remains the source for target/layer role action state until later state-model work.
- Resource schemas remain unchanged.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Sample resources as completion | reject | Production screen completion must show missing/project state, not silent samples. | none | Existing and new tests assert sample mode stays off. |
| Raw path labels | reject as primary UI | Paths belong in tooltips/debug reports, not first impression. | none | Tests assert path text stays out of primary summaries. |
| Export package build UI | defer | Product decision is scheduled. | `EXPORT-NEXT-10` complete. | Queue dependency. |
| Layer role editing | defer | Fine-grained editing is scheduled. | `LAYER-NEXT-10` complete. | Queue dependency. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Resources selected node | Summary distinguishes no target, selected target, unique/shared/optional readiness, and next action. | Resources remains a list of pickers without workflow clarity. | Resources snapshot tests. |
| Resources dependencies | Source badges explain Node / Document Dependency / Manual Override / Missing without primary path labels. | User cannot tell ownership/source. | Source badge row tests. |
| Layers role tree | Role tree summary names counts and per-role visible/locked/writable state. | Role list is hard to scan. | Layers snapshot and mounted text tests. |
| Export runtime handoff | Readiness rows show source/destination/profile/action/result state. | Export appears as a generic ResourcePicker surface. | Export snapshot and mounted text tests. |
| Deferred package/role work | Deferred scope maps to existing queue items. | SCREEN-NEXT-10 overclaims completion. | Self-review and queue proof. |

## Completion Rule

`SCREEN-NEXT-10` is complete only when Resources, Layers, and Export expose richer screen-surface snapshots and mounted UI labels, tests cover those surfaces, no sample-only proof is used, and `./tools/test.sh` passes with UI metric P0 failures = 0.
