# CATUI-01 Policy

## Roadmap Alignment

CATUI-01 implements the normal UX path for catalog-backed floor, wall, overlay, and object defaults. Numeric tile controls are retained as an advanced fallback per `SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md`.

## Compatibility

- Existing tests that set source and atlas spin boxes must continue to pass.
- Catalog selectors must write through the same payload dictionaries/options already used by Generate Dock and Edit Dock.
- Empty or missing catalog selections must not clear numeric fallback values.

## Architecture

- Keep changes inside existing editor helper boundaries for this task.
- Do not introduce a new large editor component until the queued architecture tasks run.
- Avoid editor-only APIs in code paths used by headless tests.

## Repair Classification

- `repair-now`: failing selector behavior, broken numeric fallback, or missing test proof.
- `follow-up-ready`: polish such as full resource picker support or richer catalog filtering that is not required for acceptance.
- `manual-optional`: visual review of exact dock layout.
