# DOC-70 IMPLEMENTATION PLAN

## Scope

Update user-facing workflow docs for the completed Build/Paint/Export route.

## Target Files

- `docs/manual/MANUAL_WORKFLOW.md`
- `README.md`

## Planned Steps

1. Rewrite `MANUAL_WORKFLOW.md` opening workflow to start with Build graph, Promote, Paint, and Export handoff.
2. Keep setup, catalog, layer, validation, runtime query, and object export details as supporting/reference sections.
3. Replace old Generate/QA/Validate-first pass wording with Build/support wording.
4. Update README editor authoring paragraph to match the manual.
5. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Docs no longer present Resource rows as the primary workflow.
- The primary path is `Build graph -> Promote layer -> Paint -> Export handoff`.
- QA/Validate are documented as support/parked, not the main route.
- No analog test is added.
