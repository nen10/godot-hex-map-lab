# STATE-NEXT-11 UX

## User Goal

Keep Generate flow behavior stable while consolidating generation state ownership in `HexMapGenerationRunState` so UI and tests observe a single source-of-truth for running/cancel/progress UI signals.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Keep `_generation_*` state mirrors in the dock and update both mirrors and run-state | high | medium | low | reject | Keeps stale dual-write risk and conflicts with state ownership. |
| Remove mirror writes and route generation state through `HexMapGenerationRunState` | high | low | medium | adopt | Aligns behavior with existing UI contract and reduces drift risk. |
| Change visible progress/cancel UX behavior to avoid minimum-delay handling | high | high | medium | reject | Behavior change violates acceptance. |
| Remove progress/cancel UI nodes as read-only derived text | medium | high | low | reject | Would regress existing UI behavior. |

## Adopted UX

- Keep run-state source-of-truth for generation lifecycle and progress/cancel controls.
- Preserve all UI-visible progress and cancel semantics (progress bar visibility, cancel-button disabling, minimum hide delay behavior).
- Preserve UI nodes as direct handles only; they read from derived run-state snapshots.

## Deferred UX

- No UX flow behavior changes beyond ownership cleanup.
- No new analog/manual visual check required for CLEAN UI pass per roadmap instructions.
