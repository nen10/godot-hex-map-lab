# GQM-17 Criteria Window DoD UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Reuse existing criteria windows and repair only confirmed discomfort | high | low | low | adopt | Keeps scope aligned with V8 DoD instead of redesigning already-working asset grammar. |
| Treat Markov `1.0` as integer-format issue | low | medium | low | reject | The relevant UX failure would be an inability to express `8.0`; the correct scale remains float. |
| Show Markov `8.0` in the probe capture | high | low | low | adopt | Makes the accepted range visible instead of relying on code reading. |
| Keep Adjacency pattern keys handwritten in the probe | low | high | low | reject | Handwritten cube/axial-order strings produced false all-white pattern evidence. |
| Fit Adjacency initial dialog inside the verification viewport | high | low | low | adopt | The user can inspect and edit the rule name, preset row, patterns, and default probability without horizontal clipping. |

## User Goal

Users editing graph criteria can open each criteria surface and see the active parameters reflected without needing to infer hidden state, decode raw data, or work around clipped controls.

## Experience Steps

1. Open Markov Mesh distribution.
2. See asset operations, reference patterns, and weight SpinBoxes.
3. Confirm weight controls cover `0.0..8.0` and visibly accept `8.0`.
4. Open Adjacency Rules.
5. See rule-set name, preset operations, black/white reference toggles, component labels, pattern probabilities, and default probability without clipped primary fields.
6. Switch Item Pool between limited and weighted modes.
7. See row labels and criteria chip remain stable across the method change.

## Rejected UX

- Integer-only Markov weight display.
- Raw direction-key strings as user-facing proof.
- Enlarging the Adjacency dialog beyond the first viewport as an initial state.
