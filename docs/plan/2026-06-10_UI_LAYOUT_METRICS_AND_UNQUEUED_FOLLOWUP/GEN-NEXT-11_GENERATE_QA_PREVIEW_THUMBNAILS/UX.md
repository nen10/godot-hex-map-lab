# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Text-only row summary | low | medium | low | reject | Users still cannot visually compare candidates. |
| B. One shared thumbnail for current Generate candidate and selected QA seed | high | low | medium | adopt | Establishes connected preview without redesigning all tables. |
| C. Thumbnail in every table row as a full Control | high | medium | high | defer | Full table redesign belongs to `QA-NEXT-10`; row preview payload is enough for this slice. |
| D. Use sample atlas/catalog tiles for prettier thumbnails | medium | high | medium | reject | Would violate sample-only completion and sample fallback policy. |
| E. Lightweight cell-shape drawing from candidate data | high | low | medium | adopt | Shows real candidate shape/wall/overlay occupancy from generated data. |

## User Goal

The user should see whether a generated candidate or selected seed row roughly matches the desired map shape before applying or promoting it.

## Adopted UX

- Generate Preview section shows a current candidate thumbnail when a preview exists.
- Generate Seed Lab selected row uses the same thumbnail contract.
- QA Seed Lab shows selected seed preview and score rows carry preview payloads.
- The preview uses generated map/overlay/document data and identifies empty/unavailable states.
- Thumbnails are bounded by a small preview budget and do not depend on sample assets.

## Rejected / Deferred UX

- No full QA table visual redesign in this task.
- No TileSet/PackedScene renderer parity.
- No sample atlas, sample catalog, or sample screenshot fallback.

## Experience Steps

1. User generates a candidate and sees a thumbnail in Generate Preview.
2. User runs Seed Lab and selects a row; the selected seed thumbnail updates.
3. User opens QA and sees the same selected seed preview through QA context.
4. Score rows include preview payloads so the next QA table redesign can render row thumbnails without changing generation data flow.
5. User promotes a seed knowing the preview came from the candidate data, not bundled samples.
