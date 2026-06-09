# STATE-10 Policy

## Adopted Decisions

- The run state helper is the source for Generate status snapshots and control ViewState.
- Existing private fields may remain as mirrors during this task to avoid destabilizing generation internals.
- Tests should assert ViewState/state snapshots rather than new private fields.

## Boundaries

- Generation algorithms, shape options, catalog behavior, and output document schema are not redesigned here.
- Generate visual layout cleanup remains in `UI-03`.
- Performance budget and chunked apply policy remain in `PERF-60`.
