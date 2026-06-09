# CLEAN-41 API Docs Clean Vocabulary UX

## Goal

Make public API documentation and runtime examples present canonical Resource objects as the primary authoring/runtime contract.

## User Contract

- Public docs do not describe `v2`, migration, legacy, or compatibility cleanup as normal API concepts.
- `HexMapDocumentResource` and related Resource objects are the first documented path for level documents, catalogs, objects, labels, dependencies, and runtime queries.
- Path-based helpers remain documented only as supplemental load/save conveniences.
- Catalog entry source/atlas details are documented as entry internals, while catalog keys are the gameplay-facing vocabulary.

## Non-Goals

- CLEAN-51 owns broader canonical resource test expansion.
- Editor UI manual organization was completed by CLEAN-40.
