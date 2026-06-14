# STATE-NEXT-10 UX

## User Goal

Make `HexMapWorkspaceDispatcher` event handling explicit and testable by separating reducer output, side effects, and UI update hints while preserving existing behavior and null/unknown handling.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Adopt typed event model with single validated event descriptor map | high | medium | low | adopt | Reduces implicit behavior and centralizes routing.
| Keep current loose string event flow | medium | high | low | reject | Harder to validate unknown events and reason about side effects.
| Keep only reducer output (`result`) | high | high | low | reject | Loses side-effect and UI refresh traceability.
| Replace event consumers with opaque action IDs | medium | medium | medium | reject | Adds external coupling without visible improvement.

## Adopted UX

- Event dispatch stays API-compatible by retaining existing event string constants used by the current workspace UI path.
- Dispatch result now exposes `reducer_result`, `side_effects`, and `ui_state_update` in addition to standard envelope fields.
- Unknown events return typed failure results; null workspace returns typed unavailable results.

## Deferred UX

- A new first-class event bus is deferred to the architecture phase to avoid overreach in this task.

## Experience Steps

1. Convert event declaration into enum + string descriptor registry.
2. Validate incoming event IDs through one mapping before handler execution.
3. Return structured dispatch contract from every handler.
4. Update tests to assert structured sections and preserve existing root/view-state behavior.
5. Update queue evidence and complete `STATE-NEXT-10`.
