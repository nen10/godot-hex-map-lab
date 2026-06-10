# PROCESS-12 Policy

## Adopted Decisions

- The fallback ledger is a review document under `docs/review/roadmap/`.
- Ledger rows must include category, owner, status, removal condition, test proof, and queue connection.
- Intentional states, such as manual override precedence, can remain if they are named and tested.
- Temporary mirrors must have a removal task or removal condition.
- Sample and debug surfaces must remain visibly distinct from production completion paths.

## Rejected Decisions

- Do not use the ledger to justify hidden fallback behavior.
- Do not create duplicate queue tasks where the current roadmap already has a task id.
- Do not treat sample success as production completion.
- Do not preserve legacy numeric fallback or raw path/raw JSON normal UI as UX.

## Invariants

- `fallback`, `mirror`, `legacy`, `debug`, `sample`, and `manual override` are not acceptable as unstated assumptions.
- Every ledger row has an owner.
- Every temporary row has a removal condition or a queue id that owns removal.
- Every retained row has test proof.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Manual override precedence | retain as explicit source state | User-selected project Resources must not be silently overwritten by hydration. | none unless product policy changes | Dependency hydration/manual override tests. |
| Sample learning source | retain as learning-only state | Samples are onboarding assets, not production source fallback. | none for learning source; production fallback remains forbidden | Sample mode and duplicate-to-project tests. |
| Debug/raw detail surface | retain only in debug/report surfaces | Debug details are useful for support but must not leak into normal UI. | Normal UI contract and metric gates pass. | UI screen contracts and future UI metric gates. |
| Legacy numeric fallback | forbid in normal production/UI path | Missing catalog assignment must be a validation issue, not a hidden tile fallback. | Existing validation/test proof stays green. | Adapter/editor tests for numeric fallback absence. |
| Private generation mirror flags | temporary mirror, queued removal | State refactor used mirrors as transition support. | `STATE-NEXT-11` inventory and removal/read-only decision complete. | Generation run state tests plus `STATE-NEXT-11`. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Manual project override | Explicit user override wins over document hydration until cleared. | Hydration silently changes user-selected source. | Ledger row plus existing dependency hydration tests. |
| Sample mode off | Main Generate/Paint/Catalog flow does not use bundled samples as fallback. | Sample-only completion is mistaken for production feature completion. | Ledger row plus sample mode tests and future P0 gate. |
| Debug/report mode | Raw paths/internal details live in debug report, not normal visible UI. | Debug leakage harms first impression and hides real state design. | Ledger row plus screen contract tests and UI metric work. |
| Generation mirror transition | Old `_generation_*` fields are read-only mirror or removed after state replacement. | Duplicate state diverges. | Ledger row plus `STATE-NEXT-11`. |

## Resource / API / UI Boundary

- Resource/API behavior is not changed in this task.
- UI behavior is not changed in this task.
- The ledger records source-of-truth decisions that later UI/API tasks must respect.
