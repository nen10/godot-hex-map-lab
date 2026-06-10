# DOC-90 Policy

## Adopted Decisions

- Treat the selected Level Document and selected `HexTileMap` relationship as the production source of truth.
- Document source badges as resource ownership signals, not debug labels.
- Keep bundled samples as learning/duplication assets separate from production completion.
- Update docs and test coverage notes only; this slice does not change runtime/editor behavior.

## Rejected Decisions

- Do not present bundled samples as automatic production fallbacks.
- Do not use raw paths, raw JSON, or numeric fallback language as the main workflow.
- Do not add analog tests for this documentation-only slice.

## Resource / API / UI Boundary

- Manuals describe user operations and ownership semantics.
- API details remain in `docs/api/API_REFERENCE.md`.
- Source badge meanings describe visible UI contract and ownership state, not internal implementation flags.

## Compatibility

The addon is unpublished. The manual should describe the current workflow and not preserve old UI wording for compatibility.
