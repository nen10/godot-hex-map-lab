# Sub Tasks

## Complexity

Class: C4
Reason:
- The task connects viewport input traces to the visible Paint tab screen contract.
- Completion requires mounted UI/snapshot proof for brush cursor, selected cell, target layer, mode, and last edit feedback.
- The work must not reintroduce document/layer/resource management into Paint.

Required artifacts:
- Task resolution candidate matrix.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Fallback / Mirror Handling table.
- State / Invariant Table.
- Dependency / Test Matrix.

## Task Resolution Candidate Matrix

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Add a Paint affordance board from interaction state and last edit trace | high | adopt | Makes viewport feedback explicit and testable in the Paint surface. |
| B. Add new viewport input mechanics | low | reject | Existing viewport edit path already works; this task is affordance polish. |
| C. Add mounted affordance label in `HexMapEditTool` | high | adopt | Paint tab is physically hosted by the edit tool. |
| D. Duplicate document/layer management controls in Paint | low | reject | Ownership remains Resources/Layers. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `PAINT-NEXT-10.01` | Add Paint affordance board snapshot rows for cursor, mode, target, selected cell, and last edit. | Snapshot tests. |
| `PAINT-NEXT-10.02` | Add mounted Paint affordance label and refresh it with viewport/edit state. | Mounted text tests. |
| `PAINT-NEXT-10.03` | Exercise viewport input through Workspace Paint snapshot. | Test asserts cursor/cell/target/mode/last edit sync. |
| `PAINT-NEXT-10.04` | Update docs, run tests, self-review, queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Brush rendering/canvas cursor visuals beyond existing highlight | none | reject | Existing target highlight is the actual viewport feedback path; this task exposes it clearly. |
| Paint resource management rows | none | reject | Resources/Catalog/Layers own setup and management. |
| Root reducer event model | `STATE-NEXT-10` | defer | This task uses existing interaction state and snapshots. |

Scheduled task:

None. Existing queue rows cover state architecture work.
