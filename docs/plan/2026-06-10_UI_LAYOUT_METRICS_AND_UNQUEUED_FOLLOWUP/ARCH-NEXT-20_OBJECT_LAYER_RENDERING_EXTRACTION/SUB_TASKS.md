## Complexity

Class: C3
Reason:
- Responsibility extraction spans runtime adapter and runtime rendering behavior used across map + instance paths.
- It touches rendering ownership, runtime instancing lifecycle, and existing public APIs in runtime code and tests.
- The edit is bounded to one runtime seam and includes plan/test proof updates.

Required artifacts:
- Task resolution candidate matrix.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Fallback / Mirror Handling table.
- State / Invariant table.
- Dependency / test matrix.

## Task Resolution Candidate Matrix

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Keep all object-layer instancing and marker code inline in HexTileMapLayer | preserve current style only | reject | Fails acceptance boundary requirement. |
| B. Extract instance-layer lifecycle + marker draw to HexObjectLayerRenderer | seam extraction with minimal behavior risk | adopt | Keeps behavior while isolating runtime boundary. |
| C. Extract only scene tile application; keep direct instances in HexTileMapLayer | partial extraction | reject | Remaining boundary is still mixed and violates acceptance. |
| D. Move boundary into gameplay queries screen component | unrelated scope | reject | Wrong layer; this task is runtime runtime rendering/instancing extraction only. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `ARCH-NEXT-20.01` | Route object instance layer lifecycle and instancing calls through a dedicated renderer seam | `apply_object_instances()` and `object_instance_layer()` still public and produce identical behavior. |
| `ARCH-NEXT-20.02` | Move object marker rendering invocation to renderer seam while preserving payload marker format | `_draw_overlay()` no longer iterates marker draw directly. |
| `ARCH-NEXT-20.03` | Add seam assertions in `tests/test_hex_tile_map_layer.gd` for parent/count/marker-path behavior | Proof that runtime results still come through seam APIs. |
| `ARCH-NEXT-20.04` | Update queue and review artifacts, then execute standard test path | `./tools/test.sh` and queue proof update. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Separate gameplay query services | `ARCH-NEXT-21` | deferred | Follow-up architectural task already queued. |
| Debug overlay extraction from payload markers | `ARCH-NEXT-22` | deferred | Different extraction scope from this task. |

Scheduled task:

None.
