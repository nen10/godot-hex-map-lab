# QA-NEXT-10 Policy

## Scope

QA-NEXT-10 is a UI presentation task over the existing Seed Lab generation batch results. It may add structured table state and mounted table controls, but it must not redefine generation scoring semantics.

## Requirements

- QA owns the score table presentation.
- The scored table must expose rank, seed, score, validation, selected, preview, and promotion columns.
- Mounted UI proof is required.
- Preview state must come from generated candidate data, not bundled samples.
- Promotion state must reflect the existing `promote_qa_selected_seed_to_document()` path.

## Fallback / Defer Ledger

| item | disposition | rationale |
|---|---|---|
| New scoring formula | defer | Not necessary for visual table redesign. |
| Row thumbnail controls | defer | Existing preview payload and selected thumbnail satisfy this slice. |
| Placeholder promote buttons per row | reject | Per-row text state is enough; action remains existing selected-seed promotion. |

## Test Policy

- Use existing editor workflow test for QA Seed Lab.
- Assert mounted UI table state, not only headless data.
- Run `./tools/test.sh`.
