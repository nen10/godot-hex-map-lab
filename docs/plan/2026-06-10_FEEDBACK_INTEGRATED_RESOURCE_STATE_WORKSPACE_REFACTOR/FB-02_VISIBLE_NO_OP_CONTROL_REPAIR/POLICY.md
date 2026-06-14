# FB-02 Policy

## Adopted Decisions

- A visible button must have a direct user-facing state change.
- A disabled button must have tooltip text explaining its disabled condition.
- `Details` is not a normal Resource row workflow in this roadmap and should not remain as a visible button.
- Headless editor tests may verify visible control inventories and tooltip contracts.

## Rejected Decisions

- Do not keep placeholder controls for compatibility with old UI shape tests.
- Do not replace `Details` with temporary labels.
- Do not hide real, functional controls from Paint/Edit Tool in this safety repair task.
- Do not use bundled sample success as completion proof for production Resource rows.

## Breaking Change Rationale

Removing a visible `Details` button is an intentional UI cleanup for an unpublished addon. The old button exposed implementation detail instead of a meaningful task. Tests and internal snapshots should follow the roadmap UX, not preserve placeholder UI.

## Resource / API / UI Boundary

- Resource/API: unchanged.
- UI: visible no-op and disabled explanation contract changes.
- Tests: editor tests verify remaining actions and disabled tooltips.
- Docs: `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` records the FB-02 coverage.

## Task-Local Decisions

- Keep the internal details container methods if they are still useful for deterministic tests and debug snapshots; do not expose them through a visible button.
- Treat Paint/Edit Tool non-paint actions as later migration work unless they are visibly no-op.
