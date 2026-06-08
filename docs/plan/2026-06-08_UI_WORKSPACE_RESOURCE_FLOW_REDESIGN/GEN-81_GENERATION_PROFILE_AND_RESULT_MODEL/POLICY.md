# GEN-81 Generation Profile And Result Model Policy

Date: 2026-06-08

## Decisions

- Define model boundaries before adding schema code.
- Treat current document metadata as provenance summary, not a full generation graph.
- Keep QA Seed Lab rows as candidate summaries until a Generation Result resource exists.
- Keep graph editor out of scope.

## Non-goals

- Do not implement `GenerationProfileResource` or `GenerationResultResource` in this task.
- Do not migrate existing documents.
- Do not add analog tests.
