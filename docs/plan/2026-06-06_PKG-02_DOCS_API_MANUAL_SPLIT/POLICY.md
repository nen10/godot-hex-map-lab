# PKG-02 Policy

Task: `PKG-02`  
Created: 2026-06-07  
Status: RUNNING

## Decisions

- `docs/api/` is for callable/resource API surface and should be terse.
- `docs/manual/` is for user workflows and should avoid implementation-history narration.
- `README.md` should act as an entry index, not duplicate the manuals.
- Docs must cover setup, document v2, catalog/layer stack, validation, runtime query, and examples.
- Existing manuals stay compatible; new pages link to them instead of replacing them wholesale.

## Compatibility

- Docs-only implementation.
- No API or saved resource schema changes.
- Test proof still uses `./tools/test.sh` to guard accidental resource/script breakage.

