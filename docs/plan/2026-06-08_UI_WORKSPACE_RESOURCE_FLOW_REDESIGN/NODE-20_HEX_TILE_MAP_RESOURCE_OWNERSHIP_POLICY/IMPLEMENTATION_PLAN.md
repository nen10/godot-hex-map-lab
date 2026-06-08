# NODE-20 Implementation Plan

## Scope

- Write `NODE_RESOURCE_OWNERSHIP_POLICY.md`.
- Classify UniqueResource, SharedResource, and OptionalResource.
- Record current source notes and implementation gaps.
- Update queue proof after verification.

## Change Targets

- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/NODE_RESOURCE_OWNERSHIP_POLICY.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/review/autopilot/NODE-20_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/NODE-20_TEST_RESULT_2026-06-08.md`

## Steps

1. Inspect `HexTileMapLayer` exported fields and document apply paths.
2. Inspect workspace asset context slots and resource factory types.
3. Classify each resource.
4. Record Resources tab display guidance.
5. Run `./tools/test.sh`.
6. Self-review and update queue dependencies.

## Deferred Steps

- Do not add node exported fields in this task.
- Do not implement auto-binding in this task.
- Do not create resources in this task.
- Do not add analog tests.

## Test Path

```sh
./tools/test.sh
```

## Completion Checklist

- UniqueResource / SharedResource / OptionalResource are classified.
- Noisy always-on resources are documented.
- Resources tab display grouping can follow the policy.
- Current implementation gaps are explicit.
