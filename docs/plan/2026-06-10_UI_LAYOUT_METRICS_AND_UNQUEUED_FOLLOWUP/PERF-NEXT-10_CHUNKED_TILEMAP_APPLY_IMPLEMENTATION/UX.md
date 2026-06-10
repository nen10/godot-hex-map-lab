# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Explicit inline progress for Generate apply | high | low | medium | adopt | Users get visible busy/progress state during large generated-result apply. |
| Modal progress window | low | medium | medium | reject | Existing process avoids modal progress windows for Generate apply. |
| Full visual layout redesign of Generate output | high later | high | high | reject | `GEN-NEXT-10` owns visual layout redesign. |
| Silent chunking without snapshot proof | low | medium | low | reject | Acceptance requires visible/testable progress and scope. |

## User Goal

Applying a generated or document-backed map to a TileMap target should have an explicit target scope and progress state, with clear cancellation checkpoints for large work.

## Adopted Experience

- Generate continues to use inline progress controls.
- The apply step reports target scope, chunk size, applied cells, total cells, and completion/cancel state.
- Existing Apply buttons and output target states remain in place.
- No new modal window, debug-only UI, raw path dump, or sample-only completion path is introduced.

## Experience Steps

1. Generate or load map data.
2. Apply to a TileMapLayer or selected Level Document.
3. The apply path clears/writes the selected target according to the active policy.
4. Progress advances by chunks and records applied/total counts.
5. Cancel checkpoints can stop remaining chunks and preserve a cancelled report.
