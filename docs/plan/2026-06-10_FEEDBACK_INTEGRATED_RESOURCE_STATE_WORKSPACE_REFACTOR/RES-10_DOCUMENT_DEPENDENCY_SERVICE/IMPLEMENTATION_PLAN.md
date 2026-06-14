# RES-10 Implementation Plan

## Scope

- Add `HexMapDocumentDependencyService`.
- Extend dependency kind constants for shared project resources.
- Update dependency validation for movement/profile kinds.
- Add adapter tests for add/find/update/remove/hydrate/validate.
- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`, self-review, queue proof, and commit.

## Change Targets

- `addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd`
- `addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd.uid`
- `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
- `tests/test_hex_adapter.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/RES-10_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/RES-10_TEST_RESULT_2026-06-10.md`

## Steps

1. Add service constants for semantic dependency keys and kinds.
2. Implement `find_dependency`, `set_dependency`, `remove_dependency`, `hydrate_dependency_map`, and `validate_dependencies`.
3. Extend dependency resource kind constants.
4. Extend validator type matching for movement/profile kinds.
5. Add adapter tests for all acceptance resources.
6. Run `./tools/test.sh`.
7. Write self-review and test result.
8. Mark `RES-10` complete, sweep dependencies, and update current pointer.

## Deferred Steps

- Do not hydrate Workspace context from selected document yet.
- Do not create concrete profile classes.
- Do not change node-owned Resource binding.

## Test Path

```sh
./tools/test.sh
```

## Docs Update

Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with RES-10 dependency service coverage.

## Completion Checklist

- Service API covers dependency CRUD and hydration.
- Required/optional/type validation is covered.
- Profile kinds are available without concrete profile classes.
- `./tools/test.sh` passes.
