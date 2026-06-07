# CLEAN-25 Self Review

Date: 2026-06-07
Task: CLEAN-25 Generation QA Screen redesign

## Acceptance

- Seed Lab exposes seed count, Run Batch, score table, selected seed preview, and Promote to Document controls in `HexMapGenDock`.
- Batch rows render rank, seed, score, status, cells, and validation summary.
- Row selection updates preview state and promotion creates a canonical `HexMapDocumentResource`.
- Promotion status reports dirty state and generation metadata.

## Verification

- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- `git diff --check` PASS.

## Review Notes

- The task reuses existing batch scoring and promotion APIs rather than adding another generation path.
- The preview is textual by policy for this slice; richer map preview remains out of scope until the workspace/tab placement task gives QA panels a durable home.
- No schema migration, adapter fallback, or path-string UX was introduced.
- `repair-now`: none.

## Residual Risk

- Manual visual ergonomics of the Seed Lab table are deferred with the broader UI reorganization; headless coverage verifies the state contract.
