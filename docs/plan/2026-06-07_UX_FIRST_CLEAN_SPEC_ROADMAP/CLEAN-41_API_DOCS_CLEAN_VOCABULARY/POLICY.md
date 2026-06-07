# CLEAN-41 Policy

## Decisions

- Resource object APIs must appear before path helpers in public docs and examples.
- Keep valid low-level APIs documented, but label them as supplemental or advanced where they are not the normal authoring vocabulary.
- Do not remove path helpers from code; loading by saved path remains useful for runtime scenes and tests.
- Runtime sample wrappers should accept `HexMapDocumentResource` directly and only fall back to path loading when a Resource is not supplied.

## Verification

- Docs scan confirms no public `v2`, migration, or legacy vocabulary in targeted public docs.
- Tests confirm runtime sample query by Resource object and path fallback both work.
- `./tools/test.sh` remains the completion test path.
