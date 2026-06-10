# SAMPLE-NEXT-10 Sub Tasks

Task: `SAMPLE-NEXT-10_SAMPLE_DETAIL_DRAWER`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Adopt / Defer Decisions

| candidate | decision | reason |
|---|---|---|
| Sample detail drawer snapshot | adopt | Users need inspectable sample type/dependency/duplicate/learning-use state. |
| Mounted detail text | adopt | Completion needs visible UI proof, not only snapshot data. |
| Production sample injection | reject | Samples stay learning/duplicate sources, never silent production defaults. |
| Full per-sample preview thumbnails | defer | This task is inspection metadata; Catalog preview work already owns rich media previews. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `SAMPLE-NEXT-10.01` | Add selected sample detail drawer state. | Snapshot exposes selected sample detail with type, dependencies, duplicate target, and learning use. |
| `SAMPLE-NEXT-10.02` | Mount sample detail text in Settings Sample Learning group. | Mounted detail text updates from the selected sample. |
| `SAMPLE-NEXT-10.03` | Preserve no production injection behavior. | Existing Generate/Paint fallback assertions remain green. |
| `SAMPLE-NEXT-10.04` | Extend tests and test docs. | Settings/sample tests cover detail drawer contract. |

## Non Goals

- Do not add new sample fallback behavior.
- Do not add row preview thumbnails.
- Do not make non-duplicable sample assets production assets.
