# STATE-00 Policy

## Adopted Decisions

- P0 means the area gates multiple later tasks or currently combines flags in a way that creates contradictory user states.
- P1 means the area has visible workflow ambiguity but can follow a P0 foundation.
- P2 means the area should be cleaned after core dispatcher/view-state boundaries exist or has lower immediate user risk.
- Old UI tests should be rewritten when they verify private nodes, debug text, placeholder actions, path text, or legacy shape instead of user-visible state.

## Boundaries

- This task does not change code behavior.
- Later STATE tasks may use this inventory to justify refactors and test rewrites.
- CLEAN UI rules still apply: no new analog tests and no sample-only completion proof.
