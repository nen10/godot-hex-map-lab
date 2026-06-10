# Sub Tasks

## Complexity

Class: C4
Reason:
- TileMap apply spans direct adapter calls, HexTileMapLayer redraw, document apply, and Generate output progress.
- The task changes runtime/editor apply contracts and test expectations.
- Completion needs explicit chunk/progress/cancel proof without redesigning Generate layout.

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
| A. Full async frame-yielding TileMap renderer | maximum responsiveness | reject | Too large and risky for current architecture; would require broad signal/lifetime changes. |
| B. Add chunked apply contract with progress/cancel callbacks and wire Generate to it | performance proof | adopt | Provides explicit target scope, chunk advancement, progress, and cancellation semantics within current synchronous APIs. |
| C. Only add progress labels around existing full apply | weak proof | reject | Does not chunk work or expose cancellation checkpoints. |
| D. Move all apply behavior into new rendering service | architecture split | defer | Runtime extraction is already covered by later architecture tasks. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `PERF-NEXT-10.01` | Add chunked TileMap apply API/report in `HexMapTileAdapter`. | Tests verify chunk progress, target scope, and cancellation. |
| `PERF-NEXT-10.02` | Route document/direct apply paths through chunk reports while preserving behavior. | Existing apply tests pass; new tests inspect report state. |
| `PERF-NEXT-10.03` | Connect Generate document apply to busy/progress state and report metadata. | Output target snapshot includes chunked apply report; progress state exposes applying step. |
| `PERF-NEXT-10.04` | Update docs, self-review, and queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Large-map validation progress | `PERF-NEXT-11` | defer | Validation traversal is separate from TileMap apply. |
| Full async frame-yielding renderer | none | reject for this task | Current acceptance can be met with chunk checkpoints and reportable cancellation. |
| Runtime rendering service extraction | `ARCH-NEXT-20` / later architecture rows | defer | This task should not move runtime ownership boundaries broadly. |

Scheduled task:

None. Existing queue items cover deferred validation and runtime extraction work.
