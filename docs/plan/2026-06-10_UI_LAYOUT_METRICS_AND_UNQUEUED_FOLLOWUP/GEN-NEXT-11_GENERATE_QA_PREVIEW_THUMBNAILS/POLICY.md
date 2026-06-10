# Policy

## Adopted Decisions

- Thumbnail payloads are generated from `HexMapData`, `HexOverlayData`, or `HexMapDocumentResource` data.
- Preview drawing is bounded and stores a `budget` / `truncated` snapshot to prevent unbounded UI cost.
- QA receives previews through generated score rows; it does not invent a separate source of truth.
- Empty or blocked rows show an explicit unavailable preview state.

## Rejected Decisions

- Do not use bundled sample assets to satisfy preview availability.
- Do not make QA table redesign part of this task.
- Do not add raw generation snapshots as visible thumbnail UI.
- Do not add analog tests.

## Resource / API / UI Boundary

- `HexMapPreviewThumbnail` owns visual drawing and snapshot construction.
- `HexMapGenDock` owns current candidate and batch row preview payloads.
- `HexMapWorkspace` owns QA screen context and selected QA seed preview.
- Resource schemas remain unchanged.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Sample tile/catalog fallback | reject | Thumbnail proof must come from generated project candidate data. | none | Tests assert `sample_source == false`. |
| Text summary as fallback thumbnail | keep only for unavailable state | Empty/blocked state must be visible but not counted as rendered preview. | Candidate data exists. | Snapshot `available == false` for empty/blocked rows. |
| Row preview payload before full row UI | keep | Enables QA score table redesign later without changing row data. | `QA-NEXT-10` may render row thumbnails directly. | QA score rows expose `preview`. |
| GenerationResultResource | defer | Formal result replay is scheduled separately. | `GENPIPE-NEXT-10`. | Existing queue dependency. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Generate current candidate | Thumbnail is available only when current generated data exists. | Empty Generate screen appears to have a candidate. | Output/screen snapshot tests. |
| Generate selected seed row | Selected row preview matches the row seed/cell count. | Seed selection text and preview drift. | Seed Lab tests inspect selected preview. |
| QA selected seed | QA selected preview comes from the same score row payload. | QA invents separate preview source. | QA snapshot tests compare selected preview seed/source. |
| Blocked/failed row | Preview is unavailable with reason/status. | Failed candidate appears renderable. | Blocked row snapshot test. |
| Preview budget | Entry count is bounded. | Large maps create expensive UI. | Tests assert `entry_count <= budget`. |

## Completion Rule

`GEN-NEXT-11` is complete only when Generate and QA snapshots expose data-backed preview payloads, visible thumbnail Controls are mounted, sample fallback is absent, and `./tools/test.sh` passes with UI metric P0 failures = 0.
