## Complexity

Class: C3
Reason:
- The task introduces a new runtime query service and re-routes multiple existing map query APIs through it.
- It requires coordination across runtime, query tests, and a runtime sample to prove both behavioral parity and API continuity.
- Execution risk is in edge-case parity (weights, passability, toric wrapping), but scope is bounded to one boundary extraction.

Required artifacts:
- Task resolution candidate matrix.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Fallback / Mirror Handling table.
- State / Invariant Table.
- Dependency / Test Matrix.

## Task Resolution Candidate Matrix

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Keep gameplay path/range/connectivity logic in `HexTileMapLayer` and add no façade | preserve behavior only | reject | does not satisfy boundary clarification target in Phase M6. |
| B. Extract a new `HexGameplayQueryService` and make `HexTileMapLayer` methods delegate | preserve public API and clarify ownership | adopt | aligns with acceptance and existing layered structure. |
| C. Move service extraction into an editor-only runtime helper | reduce runtime code coupling | reject | runtime query usage belongs in runtime adapter, not editor-only. |
| D. Replace sample query scripts with ad-hoc copy of logic | keep scripts simple | reject | duplicates logic and reintroduces drift risk. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `ARCH-NEXT-21.01` | Add `HexGameplayQueryService` with map-based gameplay query methods and null-safe behavior | service file + unit test coverage in `tests/test_hex_tile_map_layer.gd` |
| `ARCH-NEXT-21.02` | Make `HexTileMapLayer` delegate query methods to service while preserving signatures | delegation assertions in `tests/test_hex_tile_map_layer.gd` |
| `ARCH-NEXT-21.03` | Update runtime sample query script to use service path (`find_weighted_path`/`movement_range` through service) | runtime sample assertions in `tests/test_debug_scenes.gd` |
| `ARCH-NEXT-21.04` | Update queue proof and add self-review/test-result entries for completion evidence | `IMPLEMENTATION_QUEUE.md` + `docs/review/autopilot/*` |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Gameplay connectivity service extraction from `HexTileMapLayer` | `ARCH-NEXT-22` | reject | same queue family but different scope; this task owns gameplay query extraction only. |
| Debug overlay extraction | `ARCH-NEXT-22` | defer | different extraction boundary and runtime overlay rendering responsibility. |

Scheduled task:

None.
