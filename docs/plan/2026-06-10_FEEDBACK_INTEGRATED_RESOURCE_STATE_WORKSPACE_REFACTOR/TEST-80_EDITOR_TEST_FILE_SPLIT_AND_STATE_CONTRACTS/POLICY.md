# TEST-80 Policy

## Adopted Decisions

- Split coverage into focused GDScript test files for state transitions, hydration/writeback, and screen contracts.
- Keep integration tests where they exercise real editor nodes and workflow behavior.
- Replace stale UI shape assertions with state/snapshot assertions when possible.
- Run all new scripts through `./tools/test.sh`.

## Rejected Decisions

- Do not add analog tests.
- Do not mechanically move every editor test in one task.
- Do not preserve tests that only defend old private widget structure.

## Resource / API / UI Boundary

- Resource/API tests should assert service and Resource state directly.
- UI tests should assert public screen snapshots and ViewState, not private control arrangement, unless the control itself is the user action under test.
- Integration tests may still touch widgets when verifying a real button/selector action.

## Compatibility

The addon is unpublished. Tests should protect current UX contracts, not compatibility with old UI internals.
