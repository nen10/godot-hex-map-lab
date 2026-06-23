# REPAIR-11 Codex Handoff

日付: 2026-06-23
対象 executor: Codex
状態: READY

## One-line assignment

Implement `Result` as a final projection bundle with required `terrain` plus optional `overlay_0`, `overlay_1`, `overlay_2`, and prove that all connected overlays are preserved as separate generated overlay layers through Generate / viewport preview / Apply / Revert.

## Read first

1. `docs/policy/IMPLEMENTATION_POLICY.md`
2. `docs/TEST.md`
3. `docs/process/AGENT_ROSTER_AND_ROUTING.md`
4. `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/SUB_TASKS.md`
5. `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/POLICY.md`
6. `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/IMPLEMENTATION_PLAN.md`

## Critical design decisions already made

- Use fixed numbered Result overlay ports for this repair:
  - `overlay_0`
  - `overlay_1`
  - `overlay_2`
- Do not implement dynamic overlay slot add/remove UI.
- `terrain` is required.
- Old `Result.overlay` input is not part of the new primary contract.
- Keep legacy `HexGenerationResultResource.overlay_map` as a mirror of the first overlay.
- Add `HexGenerationResultResource.overlay_maps` for the real multi-overlay contract.
- Do not merge overlays into one generated overlay.
- Do not route final proof through `Compose`.

## Implementation checklist

### Graph contract

- [ ] `HexGenerationNodeTypes.NODE_RESULT` input schema is exactly:
  - required `terrain`, accepts `terrain`
  - optional `overlay_0`, accepts `overlay`
  - optional `overlay_1`, accepts `overlay`
  - optional `overlay_2`, accepts `overlay`
- [ ] Add helpers/constants for Result overlay ports.
- [ ] `HexGenerationGraph.validate()` rejects duplicate edges into the same input port with code `duplicate_input_edge`.
- [ ] `Result -> Result` is invalid by type mismatch.

### Runtime output

- [ ] `_run_result()` appends every present overlay input to `result.overlay_maps` in numeric port order.
- [ ] `_run_result()` sets `result.overlay_map` to the first overlay only for legacy compatibility.
- [ ] `_run_result()` writes metadata:
  - `overlay_inputs`
  - `overlay_count`
  - `overlay_conflicts`

### Projection

- [ ] `HexGenerationPromote` can preserve existing generated overlays during multi-overlay Result promotion.
- [ ] `HexMapBuildScreen._promote_result_report()` promotes terrain and every overlay.
- [ ] Each overlay becomes a separate generated overlay layer:
  - `generated_overlay_0`
  - `generated_overlay_1`
  - `generated_overlay_2`
- [ ] `_last_promote_result` records overlay count, overlay layer ids, overlay results, and conflicts.
- [ ] Existing viewport projection success checks remain the source of truth.

### UI/snapshot

- [ ] Result node shows `terrain`, `overlay_0`, `overlay_1`, `overlay_2` slots.
- [ ] Selected Result/build snapshot exposes overlay count and/or overlay input summary.

## Required tests

Add or extend tests to prove:

1. Missing `Result.terrain` is invalid.
2. Duplicate edge into the same `Result.overlay_0` is invalid with `duplicate_input_edge`.
3. `Result -> Result` is invalid.
4. Graph resource roundtrips `overlay_0` and `overlay_1`.
5. Runtime Result with two overlays has `overlay_maps.size() == 2`.
6. Runtime overlay order follows `overlay_0`, then `overlay_1`, even if graph edges were added in reverse order.
7. Legacy `overlay_map` mirrors `overlay_maps[0]`.
8. Conflict metadata appears when two overlay inputs contain the same `item_key` at the same cell.
9. Build screen Result preview creates two separate generated overlay layers.
10. Apply/Revert restores the pre-preview document state including overlay layers.
11. Canvas can connect to `overlay_0` and `overlay_1`.

## Run command

```sh
./tools/test.sh
```

If tests cannot run because the environment has no Godot executable, record `BLOCKED_BY_TEST_ENV`. This machine is expected to have:

```text
/Applications/Godot.app/Contents/MacOS/Godot
```

## Queue/proof update

On completion:

- Update only the `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT` row in the implementation queue.
- Add a proof entry for `REPAIR-11`.
- Do not change the recommended-next pointer unless the queue policy explicitly requires it for this branch.
- Do not mark other repair tasks complete.

## Self-review requirements

The final self-review must mention every changed source file and test file. It must explicitly state:

- Whether `overlay_map` legacy mirror remains.
- Whether old `"overlay"` Result port remains anywhere in active code.
- How duplicate input edges are handled.
- How Apply/Revert was tested.
- The exact `./tools/test.sh` result.
