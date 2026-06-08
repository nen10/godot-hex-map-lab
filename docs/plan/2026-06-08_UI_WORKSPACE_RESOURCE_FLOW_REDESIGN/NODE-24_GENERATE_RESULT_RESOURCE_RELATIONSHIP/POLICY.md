# NODE-24 Policy

## Adoption

- Generated data has two visible states: preview runtime display and committed Level Document content.
- `Preview only` must not mutate `HexTileMapLayer.level_document_resource`.
- `Apply to selected Document` mutates the selected node's existing `level_document_resource` and synchronizes workspace/session context to that document.
- Generated document metadata must include generation snapshot, seed, validation summary, source, and output target classification.

## Boundaries

- Generate dock owns generation snapshot, validation summary, output target status, and document-apply action.
- Workspace/session context owns selected node and Resource relationship visibility.
- `HexMapDocumentAdapter.copy_document_state()` is the canonical document replacement mechanism.

## Non-Adoption

- No implicit Level Document creation from Generate in this task.
- No compatibility behavior that treats runtime `hex_map` preview as the node's Level Document.
- No sample catalog fallback as completion proof.

## Task-Local Decisions

- Applying to selected Document requires a selected `HexTileMapLayer` and a non-null existing Level Document.
- If generated data is absent, the action blocks with `No generated preview to apply.`
- Output status is exposed through a snapshot API for UI tests without depending on private node paths.
