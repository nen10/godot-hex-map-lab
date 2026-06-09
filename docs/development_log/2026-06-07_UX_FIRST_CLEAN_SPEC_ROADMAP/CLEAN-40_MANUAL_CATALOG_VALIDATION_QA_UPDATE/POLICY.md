# CLEAN-40 Policy

## Decisions

- Organize manual content by user goal before implementation detail.
- Document path strings only as read-only status, saved resource paths, or supplemental scripting/load examples.
- Document numeric source / atlas values only as catalog-entry internals, not normal paint or generation workflow.
- Keep debug report wording support-oriented; it is not a primary authoring screen.
- Treat existing analog tests as history and do not create new analog test files.

## Verification

- Documentation review checks that the targeted manuals cover Catalog, Layer Stack, Validation, Object Placement, Generation QA, Debug Report, and Resource picker workflows.
- `./tools/test.sh` remains the completion test path even though this task is docs-only.
