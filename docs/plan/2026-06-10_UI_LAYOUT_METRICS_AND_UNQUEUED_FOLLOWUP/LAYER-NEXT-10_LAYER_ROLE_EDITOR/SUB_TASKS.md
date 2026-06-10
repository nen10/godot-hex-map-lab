# Sub Tasks

## Complexity

Class: C4
Reason:
- The task touches a visible workspace screen, the layer-stack resource contract, and the selected HexTileMap child node state.
- Completion requires mounted UI proof plus snapshot/API tests that edits affect both resource rows and target layer state.
- The editor must stay scoped to role properties and not absorb Paint viewport affordance or broader state reducer work.

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
| A. Add exported `locked` and `writable` fields to entry resources | medium | reject | Existing rows already store these as role metadata; schema expansion is unnecessary for this slice. |
| B. Add a workspace role editor snapshot and update API | high | adopt | Gives tests and UI a stable contract for role property editing. |
| C. Add mounted controls for selected role, visible, locked, z-index, and writable source | high | adopt | Makes the Layers tab an actual editing surface rather than a summary-only panel. |
| D. Apply edits to selected HexTileMap child role layers when present | high | adopt | Meets reflection acceptance for selected node state. |
| E. Rebuild layer management inside Paint | low | reject | Paint ownership was explicitly moved away from layer management. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `LAYER-NEXT-10.01` | Add selected role editor controls and snapshot fields to the Layers role panel. | Snapshot exposes editor controls and mounted editor text. |
| `LAYER-NEXT-10.02` | Add role property update API for visible, locked, z-index, and writable source. | Tests edit terrain role and assert resource row changes. |
| `LAYER-NEXT-10.03` | Reflect visible/z-index/locked/writable edits to selected target role nodes when present. | Tests assert the child TileMapLayer visible/z-index/meta state. |
| `LAYER-NEXT-10.04` | Update docs, run tests, self-review, queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Paint viewport role feedback | `PAINT-NEXT-10` | defer | Paint cursor/target-layer feedback is separate from editing the Layer Stack role properties. |
| Root reducer event model | `STATE-NEXT-10` | defer | This task adds a local workspace API without changing global event architecture. |
| Entry resource schema expansion | none | reject | Metadata already holds role editor fields and avoids unneeded Resource churn. |

Scheduled task:

None. Existing queue rows cover deferred Paint and state-model work.
