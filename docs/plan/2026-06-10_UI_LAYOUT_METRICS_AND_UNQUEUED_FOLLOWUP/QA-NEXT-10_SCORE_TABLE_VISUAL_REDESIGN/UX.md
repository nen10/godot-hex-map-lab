# QA-NEXT-10 UX

## User Job

A developer runs several generated seed candidates, compares their quality, picks one, and promotes it to the Level Document with enough visible context to avoid adopting the wrong seed.

## Required Visible State

| state | UX requirement |
|---|---|
| Seed rows | Rows must be comparable by rank and seed. |
| Score columns | Score must remain visible beside rank/seed. |
| Validation status | Error/warning status must be visible per row. |
| Selected seed | The active row must be visible in both table and selected seed summary. |
| Preview | Row preview availability must be visible, with selected preview shown as the mounted thumbnail. |
| Promotion state | Rows must show whether they are selected, ready to promote, or already promoted. |

## First Impression Bar

- The QA tab should read as a scored comparison table, not a generic asset panel with hidden row data.
- Empty state remains clear before a batch is run.
- After a batch run, table rows should expose enough status text for headless and UI metric proof.

## Rejections

| rejected option | reason |
|---|---|
| Raw dictionary/JSON row dump | Not user-facing. |
| Sample-only candidates | QA must work from generated project data. |
| Promotion-only selected panel | Does not make candidate comparison easy. |
