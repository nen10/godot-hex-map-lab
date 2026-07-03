# GQM-17 Criteria Window DoD Policy

## Adopted Decisions

- Probe data for Adjacency direction keys must come from `HexVector.directions()` / `HexVector.key()` so the proof uses the product's q,s,r key order.
- Markov weight controls must preserve the accepted float range `0.0..8.0` with half-step editing.
- Product code changes are allowed only after corrected probe evidence still shows a UI DoD defect.
- The Adjacency dialog initial size should prioritize usable editing at the verification viewport over showing a maximum number of pattern cards per row.

## Rejected Decisions

- Do not convert Markov weight controls to integer-only controls.
- Do not use handwritten direction strings as visual proof inputs.
- Do not add new analog tests for this CLEAN UI task.

## Resource / API / UI Boundary

| area | owner | decision |
|---|---|---|
| Markov weight values | UI + resource editor | Preserve current value model and expose `0.0..8.0`; no generation/resource schema change. |
| Adjacency pattern directions | core key format + UI proof | Probe must respect `HexVector.key()` order; product should render keys already stored in params. |
| Criteria asset operations | existing criteria UI | Keep Load / Save as / Duplicate / Inline grammar; GQM-17 only validates and lightly polishes window ergonomics. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Probe handwritten direction-key fallback | remove | It can create false product failures. | Probe uses `HexVector.directions()`. | Non-headless GQM-17 probe. |
| Markov integer-display interpretation | reject | The accepted control scale is float `0.0..8.0`. | N/A | Probe logs min/max/step and captures `8.0`. |
| Oversized Adjacency initial layout | repair | It hides the rule-name field and makes the first viewport uncomfortable. | Initial dialog fits the verification viewport. | Non-headless GQM-17 capture. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Markov custom distribution window | Every weight SpinBox covers `0.0..8.0` and accepts `8.0`. | Misreading default `1.0` as max `1.0`. | Probe log and `markov_window_weight_8_probe.png`. |
| Adjacency rule params | Pattern toggles reflect q,s,r direction keys. | False all-white pattern if probe uses q,r,s strings. | Probe-computed keys and `adjacency_window_consolidated.png`. |
| Adjacency rule-set name | Name field is editable and not truncated on open. | Primary metadata hidden by narrow field. | `adjacency_window_consolidated.png`. |
| Item pool method switch | Row labels and chip state remain stable across limited/weighted. | Criteria state appears to reset during method morph. | Item pool captures and probe chip logs. |
