# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Preserve current Generate UI while separating internal builders | medium | low | medium | adopt | Users get no visible regression while future redesign becomes safer. |
| Redesign Generate layout now | high later | high | high | reject | Full visual grouping is queued as `GEN-NEXT-10`. |
| Hide advanced controls during split | low | high | low | reject | Existing generation workflows must remain available. |
| Add invisible component ownership metadata | medium | low | low | adopt | It proves the component boundary without adding debug UI. |

## User Goal

Generate should continue to provide the same generation, source, output, and save/apply controls while the code starts reflecting those as separate task components.

## Adopted Experience

- Existing Generate controls remain visible and functional.
- Run controls, source registry controls, output target controls, and result/progress summary controls are internally attributed to separate components.
- `HexMapGenDock` remains the orchestrator for state binding, generation execution, and signal handling.
- No new placeholder controls, sample fallback, raw JSON, path text, or numeric fallback UI is introduced.

## Experience Steps

1. Open Hex Map Workspace and select Generate.
2. Use generation, seed, source registry, output target, save/apply, and progress controls as before.
3. Internally, major control groups report stable component ids and builder owners.
4. Existing tests continue to exercise generation behavior through the same public and headless paths.
