# LD2-03 Document Summary and Validation Result UX

作成日: 2026-06-07
Queue task: `LD2-03`

## Goal

Level Document v2 users and later validation/dashboard tasks need a compact document summary and a serializable validation result schema. LD2-03 adds those helper contracts without implementing the full validation rule engine.

## Operation Steps

1. Adapter code can summarize a document into counts for cells, walls, floors, objects, labels, zones, warnings, and dependencies.
2. Adapter code can create a validation result resource with summary data and issue records.
3. Validation result resources can be saved and loaded as `.tres`.
4. Later dashboard/debug-report tasks can count errors and warnings without parsing status strings.

## Maintained UX

- Current Edit/Generate/Runtime flows remain unchanged.
- v1 and v2 documents can both be summarized.

## Non-Goals

- No full validation engine rules.
- No editor dashboard UI.
- No debug report integration.
