# P0-01 Capability Matrix Policy

作成日: 2026-06-07
Queue task: `P0-01`

## Source Documents

- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`
- `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/TEST.md`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Evidence level | Adopt code + Test path evidence as the classification source. | `DOMAIN_POLICY.md` says docs alone are not implementation proof. |
| Matrix granularity | Classify by Generate / Edit / Runtime / Document / Test plus cross-cutting schema risks. | These are the Phase 0 acceptance categories and the later roadmap lanes. |
| `TileMapLayer` boundary | Treat plain `TileMapLayer` as compatibility and `HexTileMapLayer` as the richer primary target for roadmap UX. | Current tests already prioritize wrapper target resolution and runtime helper state, while plain target tests preserve compatibility. |
| Object / label payloads | Treat current object / label arrays as v1 payloads requiring typed v2 decisions. | Current resource classes expose `Array` only and cannot validate definitions or placements. |
| Overlay payloads | Treat overlay generation as strong core/editor capability but document-level overlay storage as incomplete. | `HexOverlayResource` and `HexOverlayData` exist; document integration stores overlay tile overrides inside `tile_overrides` with `kind=overlay`. |
| Follow-up handling | Put schema boundary choices in `P0-02`, not this task. | P0-01 is classification; P0-02 decides maintain/migrate/remove. |

## Fallback / Hack Classification

- Numeric `source_id / atlas_coords` tile settings are current compatibility controls, not the desired roadmap UX.
- Object and label marker display is useful existing behavior, but its untyped payload schema is not a future specification.
- Overlay item tile mapping by dictionary is useful adapter behavior, but missing catalog validation remains a risk.

## Test Policy

P0-01 adds no automated tests. Completion proof uses:

- `./tools/test.sh` execution result recorded in `docs/review/autopilot/P0-01_TEST_RESULT_2026-06-07.md`.
- Code-reading evidence from existing Test path summaries in `docs/TEST.md`.
