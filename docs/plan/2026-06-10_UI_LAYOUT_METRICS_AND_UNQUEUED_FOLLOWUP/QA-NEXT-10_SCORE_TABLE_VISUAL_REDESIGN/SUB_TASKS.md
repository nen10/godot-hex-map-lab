# QA-NEXT-10 Sub Tasks

Task: `QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Adopt / Defer Decisions

| candidate | decision | reason |
|---|---|---|
| Rich QA scored table contract | adopt | The QA tab must make seed comparison readable, not only expose raw score rows. |
| Mounted scored table widget | adopt | UI first impression requires visible table proof, not snapshot-only state. |
| Selected seed and promotion state per row | adopt | Users need to know which row is active and promotable. |
| New generation scoring algorithm | defer | Existing scoring is stable; this task is presentation and QA workflow clarity. |
| Per-row generated thumbnail controls | defer | `GEN-NEXT-11` already provides preview payloads and selected thumbnail; full row thumbnail controls can be a later visual extraction if needed. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `QA-NEXT-10.01` | Add scored table columns and row builder for rank, seed, score, validation, selected, preview, and promotion. | QA snapshot exposes structured table rows and columns. |
| `QA-NEXT-10.02` | Mount a QA score table widget in the QA Seed Lab panel. | Mounted tree row count and rich row text update after batch runs and selection. |
| `QA-NEXT-10.03` | Connect selected/promoted row state to existing Seed Lab actions. | Selection and promotion update scored table state. |
| `QA-NEXT-10.04` | Extend editor tests and test docs. | `tests/test_editor_plugin.gd` and `docs/TEST.md` cover QA-NEXT-10. |

## Non Goals

- Do not change generation candidate scoring math.
- Do not move Generate ownership back into QA.
- Do not rely on bundled sample candidates for table completion.
