# UI-METRIC-08 Policy

## Adopted Decisions

- UI task self-review must reference the UI metric report produced by `./tools/test.sh`.
- UI task completion requires P0 failures = 0.
- P1 issue count must be recorded when available, but P1 zero is not required yet.
- Metric report proof belongs in self-review or test-result docs, not in `IMPLEMENTATION_PLAN.md`.

## Rejected Decisions

- Do not make P1 zero a generic completion requirement in this task.
- Do not require metric report fields for non-UI tasks; they may mark the section not applicable.
- Do not move actual execution proof into planning docs.

## Invariants

- `SELF_REVIEW_TEMPLATE.md` remains generic enough for non-UI tasks.
- UI tasks have an explicit P0 completion boundary.
- Queue proof can link metric report evidence through review/test docs.
- Commit policy catches missing UI metric proof before commit.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Non-UI tasks using metric section | allow not-applicable | Not every task touches UI. | None. | Template text. |
| P1 report-only state | allow | P1 enforcement is not enabled yet. | Future task changes P1 policy. | Process text. |
| Metric proof in plan docs | reject | Would blur planning/execution boundary. | None. | Policy text. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| UI task self-review | References metric report and P0 failures. | Completion hides UI metric failure. | Template and process docs. |
| Non-UI task self-review | Can mark metric review not applicable. | Process noise on docs-only/backend tasks. | Template text. |
| Commit checklist | UI task completion checks P0 = 0. | Commit complete despite metric failure. | Commit policy update. |

## Resource / API / UI Boundary

- Process/template docs are updated.
- Product code is unchanged.
- Metric output remains generated under `.godot_user`.
