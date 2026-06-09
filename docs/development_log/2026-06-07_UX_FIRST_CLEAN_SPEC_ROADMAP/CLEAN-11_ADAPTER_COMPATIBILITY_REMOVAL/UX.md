# CLEAN-11 UX

## User Outcome

Game developers should see one adapter contract: a canonical document with catalog keys is applied through catalog resources. If a document lacks a catalog, default assignment, catalog key, or tile resource, the system reports a validation issue instead of silently drawing numeric fallback tiles.

## Workflow Boundaries

- Normal document apply expects validation-clean catalog assignments.
- Catalog-aware tile and overlay adapters resolve catalog keys only.
- Missing catalog/key/resource state belongs to validation result data, not display compatibility warnings.
- Direct numeric tile drawing can remain as a low-level helper for tests and debug tools, but it is not the document/catalog apply contract.

## Out Of Scope

- Object database legacy field removal belongs to `CLEAN-12`.
- Tile catalog field/type cleanup belongs to `CLEAN-13`.
- Resource picker UI and deletion of all numeric editor controls belong to `CLEAN-20` and `CLEAN-33`.
