# UI-METRIC-01 UX

## User Goal

Future metric tests should know what each important Workspace state is supposed to show and what it must never show, without reverse-engineering labels from the current implementation.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Define only root states | low | high | low | reject | Generate/Paint/Validate/QA/Export/Settings state contradictions are core metric targets. |
| B. Define tab-oriented scenarios with expected and forbidden visible output | high | low | medium | adopt | It maps directly to later snapshot evaluation. |
| C. Encode the matrix as JSON now | medium | medium | medium | reject | Human-readable docs are enough before scenario builder exists. |
| D. Include sample/debug/manual override states | high | low | low | adopt | These are frequent sources of hidden fallback and first-impression failures. |

## Adopted UX

- State ids are stable snake_case names.
- Each state has input summary, expected visible output, forbidden visible output, state sources, and primary tabs.
- The matrix names sample and debug boundaries explicitly.

## Deferred UX

- Runtime scenario construction moves to `UI-METRIC-03`.
- Automated state contradiction evaluation moves to `UI-METRIC-04` and `UI-METRIC-05`.

## Experience Steps

1. A metric test creates or simulates a Workspace state.
2. The test reads the state id from this matrix.
3. Snapshot evaluation checks expected visible output and forbidden visible output.
4. Any contradiction is reported against the state id.

## Existing UX Interference

This matrix defines desired contract, not a guarantee that every current screen already satisfies it. Current mismatch should become metric warning/failure in later tasks.
