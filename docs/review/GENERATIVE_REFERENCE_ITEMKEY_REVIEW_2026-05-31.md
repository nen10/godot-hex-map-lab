# GENERATIVE_REFERENCE_ITEMKEY Review 2026-05-31

## Findings

No issues found.

## Verification

- `HexMapGenerator.generate_toric_adjacency_items_interruptible()` appends `include_generated_reference: bool = false`.
- When enabled, generated target item cells are added to the adjacency reference set after placement using the normalized candidate cell.
- Default behavior remains static-reference-only.
- Editor adds `Generated Item Reference`, stores `overlay_generated_reference_enabled` in the snapshot, and passes it to Core.
- Tests cover core dynamic reference, toric wrap, cancel behavior, editor snapshot wiring, editor result difference, and `docs/TEST.md`.

## Residual Risk

Dynamic generated references affect only later candidates in candidate order. This is consistent with the plan.
