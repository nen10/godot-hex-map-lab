# GEN-81 Generation Profile And Result Model UX

Date: 2026-06-08

## User goal

A level designer should know the difference between generation settings, a generated preview, a persisted generation result, and the committed Level Document.

## Flow

1. Select or edit a Generation Profile.
2. Generate a preview.
3. Compare candidate previews in QA.
4. Optionally persist a result in future model work.
5. Commit a chosen result to the Level Document.

## Visible contract

- Preview is transient.
- Intermediate/result data is not the same as a committed Level Document.
- Committed documents keep concise provenance metadata.
- Graph editor remains out of scope until Resource ownership is implemented.
