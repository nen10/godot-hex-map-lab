# QA-02 Batch Runner Score Table UX

## Goal

Map generation should support seed comparison without manually changing the seed and copying debug reports for every attempt. A batch runner can generate multiple candidate seeds, validate each candidate, score the result, and expose a sortable table for later seed promotion.

## Operation Steps

1. User configures normal Generate Dock settings.
2. User requests a batch with a start seed or explicit seed list.
3. The dock generates each seed using the same snapshot settings.
4. Each row stores seed, generation counts, validation summary, and a score.
5. The score table can be sorted headlessly by score, seed, validation errors, or other row fields.

## Scope

- Add a headless-testable batch runner and sortable result table.
- Preserve the existing single Generate button behavior.
- Do not promote selected seeds to documents in this task; that is `QA-03`.

## Manual Optional Check

- Later UI can expose the table visually, but QA-02 completion is based on headless table state and tests.
