# UI-METRIC-00 Policy

## Adopted Decisions

- `docs/ui/WORKSPACE_UI_CONTRACT.md` is the Workspace UI contract source for later metric tasks.
- Component ids should align with `HexMapWorkspaceComponentRegistry` where current registry ids exist.
- Contract thresholds describe measurable UI risks, not aesthetic preferences.
- Debug, raw path, raw JSON, numeric fallback, private flag, and sample production fallback are forbidden normal UI unless a later task explicitly scopes otherwise.

## Rejected Decisions

- Do not create state matrix, static audit, snapshot collector, evaluator, or acceptance gates in this task.
- Do not change UI code to satisfy the contract in this slice.
- Do not use private node names as required contract ids when registry-backed component ids exist.

## Invariants

- Every tab has a purpose.
- Every tab has required components.
- Every tab has forbidden visible text classes.
- Every tab has at least baseline metric thresholds.
- Resource row, button/action, debug, and sample contracts are global and apply across tabs.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Sample as production fallback | forbid | Sample learning is not production completion. | Later gates prove sample fallback is absent. | `UI-METRIC-05`, sample tests. |
| Debug/raw/path detail in normal UI | forbid | First impression and normal workflow must be user-task state, not internals. | Later static/runtime metric gates detect leakage. | `UI-METRIC-02`, `UI-METRIC-05`. |
| Private mirror flags | forbid in visible UI | Mirror state can diverge and belongs in state/debug proof only. | `STATE-NEXT-11` retires generation mirrors. | `STATE-NEXT-11`, debug report proof. |
| Numeric tile fallback | forbid | Missing catalog assignment should be validation state. | Existing validation proof and later metric gates stay green. | Adapter/editor tests and `UI-METRIC-05`. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Component registry | Contract-required component ids match registry ids where available. | Contract tests target names that code cannot expose. | Compare contract to `HexMapWorkspaceComponentRegistry` during future audit. |
| Resource rows | Role/picker/status/action are stable and not path-first. | Row compression or debug details dominate first impression. | Resource row contract and future layout metrics. |
| Debug report | Raw/internal details remain copy/report content, not always-visible text. | Debug leakage in normal UI. | Debug contract and future P0 gate. |
| Sample learning | Sample UI is explicit learning/duplicate flow. | Silent sample production fallback. | Sample contract and future P0 gate. |

## Resource / API / UI Boundary

- This task changes documentation only.
- Product Resource APIs and UI code are unchanged.
- Later tests and UI tasks consume the contract.
