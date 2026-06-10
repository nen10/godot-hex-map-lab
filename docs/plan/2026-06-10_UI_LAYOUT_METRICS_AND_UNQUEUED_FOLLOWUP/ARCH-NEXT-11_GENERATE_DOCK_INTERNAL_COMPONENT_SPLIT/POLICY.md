# Policy

## Adopted Decisions

- Generate builder scripts own physical creation for key component groups.
- `HexMapGenDock` remains responsible for state, generation execution, event handling, and refresh logic.
- Component ids are stable and testable.
- Existing behavior and layout are preserved for this task.

## Rejected Decisions

- Do not redesign the Generate tab layout in this task.
- Do not retire private state mirrors in this task.
- Do not introduce sample assets as production defaults.
- Do not add analog tests.

## Resource / API / UI Boundary

| area | owner | boundary |
|---|---|---|
| Generation execution and current data/resources | `HexMapGenDock` | No behavior movement in this task. |
| Run/progress/source/output Control construction | Generate component builders | Builders create nodes and return references only. |
| Signal connections | `HexMapGenDock` | Existing handlers remain the event boundary. |
| Workspace asset context | Workspace/session + `HexMapGenDock` | Builders do not read or mutate asset context. |
| Screen snapshots | `HexMapGenDock` | Snapshot schema stays stable. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Existing `_generation_*` private fields | keep | Retiring them is explicitly queued in `STATE-NEXT-11`. | `STATE-NEXT-11` completes. | Existing generation state tests. |
| Existing visual grouping | keep | Visual redesign is queued in `GEN-NEXT-10`. | `GEN-NEXT-10` completes. | UI metric report and editor tests. |
| Builder methods returning dictionaries | keep | Low-churn bridge from monolithic dock to components. | Future Control subclasses own refresh/action wiring. | Component ownership tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Generation run state | Running/cancel/progress behavior remains unchanged. | Builder extraction drops signal wiring. | Existing async generation/progress tests. |
| Output target state | Preview/document apply/save state remains unchanged. | Output target controls lose metadata or handler. | Output target tests in `test_editor_plugin.gd`. |
| Source registry state | Source load/reload/clear UI remains unchanged. | Source list status/control references break. | Source registry tests in `test_editor_plugin.gd`. |
| UI metric gate | P0 failures stay zero. | Component split changes visible layout unexpectedly. | Runtime metric report from `./tools/test.sh`. |
