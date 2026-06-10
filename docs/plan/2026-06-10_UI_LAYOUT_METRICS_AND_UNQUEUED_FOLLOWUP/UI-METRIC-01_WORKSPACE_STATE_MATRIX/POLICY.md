# UI-METRIC-01 Policy

## Adopted Decisions

- `docs/ui/WORKSPACE_STATE_MATRIX.md` is the scenario contract source for Workspace UI metric tests.
- State ids must describe user/workflow state, not private widget state.
- Each state includes expected and forbidden visible output.
- State sources should be named so later tests can use state models/ViewState instead of private labels.

## Rejected Decisions

- Do not implement test code in this task.
- Do not make this matrix a complete product state machine.
- Do not preserve sample/debug/raw/path leakage as expected output.

## Invariants

- No state may silently convert sample learning into production readiness.
- No state may contradict selected node/resource availability.
- No state may expose raw path/node path/debug payload as normal visible output.
- Generate preview and document apply states remain visibly distinct.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Sample mode states | explicit states | Sample on/off and direct sample selection are common fallback risks. | Later metric gates prove production fallback is absent. | `UI-METRIC-05`, sample tests. |
| Manual override state | explicit state | Manual project resource selection must not be hidden by dependency hydration. | none by default | Existing manual override tests and future state metrics. |
| Debug on/off states | explicit states | Debug preference must not leak debug payload into normal UI. | Later metric gate proves debug leakage count 0. | `UI-METRIC-05`. |
| Generation private mirrors | not visible state | Mirror fields belong in debug/state proof only. | `STATE-NEXT-11` completes. | Generation state tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| No selected node | Workspace shows unconfigured/selection state, not sample defaults. | Silent sample or stale selection. | Matrix row and future snapshot scenario. |
| Selected node without resources | Missing resources are visible with next actions. | UI appears ready while required resources are missing. | Matrix row and future state contradiction metric. |
| Generate preview | Preview does not mutate Level Document. | Candidate/document boundary hidden. | Matrix row and Generate tests. |
| Validation errors | Issues expose owner/focus path, not raw object dump. | Debug payload replaces user fix path. | Matrix row and validation tests. |

## Resource / API / UI Boundary

- This task changes documentation only.
- Product state models and UI code are unchanged.
- Later scenario builder and evaluator tasks consume the matrix.
