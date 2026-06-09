# TEST-41 UX

## User Goal

Workspace tabs should have stable, queryable responsibilities so tests and future editor code can reason about tab content without depending on private node names.

## Contract

- Each workspace tab exposes expected component ids.
- Asset-owning tabs expose expected asset slot ids.
- Query methods reflect mounted tab content, not only static documentation.
- Paint owns paint-specific Object/Label slots and does not regain Document setup responsibilities.

## Non-goals

- Do not add new user-visible controls.
- Do not add analog tests.
- Do not couple tests to child node paths or private widget names.
