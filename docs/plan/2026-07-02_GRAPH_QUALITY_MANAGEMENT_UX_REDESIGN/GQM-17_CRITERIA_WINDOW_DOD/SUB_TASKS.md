## Complexity

Class: C3
Reason:
- GQM-17 is a UI-facing DoD pass over multiple criteria surfaces: Markov distribution, adjacency rules, and item pool rows.
- Completion depends on rendered screenshots, not only headless API availability.
- The task includes a verification repair: distinguish probe mistakes from product UI defects before changing product code.

Required artifacts:
- SUB_TASKS.md / UX.md / POLICY.md / IMPLEMENTATION_PLAN.md
- Rendered capture proof under `.godot_user/visual-verification/GQM-17/`
- Self-review and proof-log entry

## Task Resolution

| task candidate | decision | reason |
|---|---|---|
| Revalidate existing GQM-17 probe before product changes | adopt | The handoff explicitly suspected a probe direction-key mistake for Adjacency. |
| Convert Markov weights to integer-only display | reject | Correct product range is float `0.0..8.0`; the risk was inability to represent `8.0`, not cosmetic integer formatting. |
| Verify Markov SpinBox range and capture a visible `8.0` value | adopt | This directly answers whether the `1.0` observation was a max-range defect or only the current default value. |
| Repair confirmed Adjacency window DoD issues | adopt | After corrected keys, name-field truncation and oversized initial layout remain product-side UI friction. |
| Add new analog tests | reject | CLEAN UI work must not create new analog tests unless explicitly requested. Existing visual probe and standard gate are sufficient. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Markov integer-only presentation | none | reject | The accepted scale is `0.0..8.0`; integer-only presentation would remove valid half-step values. |
| Additional small-viewport redesign for criteria dialogs | none | reject | The 1200x860 verification viewport passes after the scoped size repair; no separate responsive redesign is required for this queue item. |
| New analog regression test | none | reject | Not requested and contrary to the current CLEAN UI testing policy. |

## Scheduled Tasks

None.
