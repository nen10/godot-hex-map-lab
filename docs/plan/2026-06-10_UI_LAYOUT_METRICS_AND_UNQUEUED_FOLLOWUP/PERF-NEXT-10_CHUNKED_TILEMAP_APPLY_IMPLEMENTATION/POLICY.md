# Policy

## Adopted Decisions

- Chunked apply proof must be a real apply contract, not label-only progress.
- Direct `TileMapLayer` applies use `HexMapTileAdapter` chunk callbacks.
- `HexTileMapLayer` may keep coordinator ownership, but its redraw must expose equivalent chunk report/progress semantics.
- Generate output target apply records the chunk report in output snapshots.

## Rejected Decisions

- Do not introduce a modal progress window.
- Do not add new sample-only proof.
- Do not expose raw debug JSON in visible UI.
- Do not rewrite runtime rendering ownership in this task.

## Resource / API / UI Boundary

| area | owner | boundary |
|---|---|---|
| Direct TileMap apply | `HexMapTileAdapter` | Computes entries, applies cells in chunks, reports progress/cancel state. |
| HexTileMapLayer redraw | `HexTileMapLayer` | Keeps override-aware display logic and exposes chunk report. |
| Document apply preparation | `HexMapDocumentApplier` / `HexMapDocumentAdapter` | Prepares document/map snapshots and passes chunk options into display apply. |
| Generate progress state | `HexMapGenDock` / `HexMapGenerationRunState` | Shows applying step and stores last chunk report. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Existing synchronous return APIs | keep | Many tests and editor callers expect immediate success/failure. | Future async apply task explicitly changes API. | Existing apply tests. |
| Full async frame yielding | reject for current task | Chunk checkpoints satisfy current acceptance without broad lifecycle work. | New roadmap task if user-facing responsiveness still needs frame-yielding. | Chunk progress/cancel tests. |
| HexTileMapLayer coordinator role | keep | Runtime extraction is queued separately. | `ARCH-NEXT-20` and follow-ups split rendering/runtime ownership. | HexTileMapLayer responsibility tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| TileMap target scope | Apply report names target kind and clear/write policy. | Apply target ambiguity remains. | New chunk report assertions. |
| Chunk progress | Progress reports monotonically increase by chunk. | Progress is label-only. | Adapter callback tests inspect applied counts. |
| Cancel checkpoints | Cancel callback stops later chunks and marks cancelled. | Cancel request ignored until full apply ends. | Adapter cancellation test. |
| Generate output result | Last apply stores chunk report and document state still updates on success. | Output target loses existing result state. | Existing NODE-24 tests plus new report assertions. |
| UI metrics | P0 failures stay zero. | Progress integration causes visible UI regression. | `./tools/test.sh` UI metric report. |
