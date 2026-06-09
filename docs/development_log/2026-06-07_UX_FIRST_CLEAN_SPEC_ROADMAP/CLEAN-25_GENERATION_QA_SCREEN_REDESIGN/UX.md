# CLEAN-25 Generation QA Screen Redesign UX

## Goal

Seed comparison and promotion should be visible in the Generate dock, not only available through helper APIs.

## User Contract

- Seed Lab exposes seed count and Run Batch controls.
- A score table lists rank, seed, score, status, cells, and validation summary.
- Selecting a row updates a selected seed preview/status.
- `Promote to Document` creates a canonical document from the selected seed and shows dirty/metadata status.

## Non-Goals

- CLEAN-31 owns final workspace/tab placement.
- CLEAN-26 owns broader validation dashboard refinement.
