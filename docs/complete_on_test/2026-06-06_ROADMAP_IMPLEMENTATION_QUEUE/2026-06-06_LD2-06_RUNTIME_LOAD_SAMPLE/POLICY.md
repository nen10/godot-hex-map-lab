# LD2-06 Runtime Load Sample Policy

作成日: 2026-06-07
Queue task: `LD2-06`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Dependency boundary | Runtime helper must live outside `addons/hex_map_kit/editor`. | Runtime users cannot depend on editor scripts. |
| Load behavior | Provide resource and path entry points. | Tests can use generated fixtures while users can load saved `.tres` files. |
| Failure behavior | Return `false` for missing/wrong resources and avoid editor status UI. | Runtime callers need simple control flow. |
| Sample surface | Prefer a debug-scene test when it is already the repository's runtime smoke-test path. | Keeps LD2-06 focused and headless-testable. |

## Test Policy

Update:

- `tests/test_debug_scenes.gd` or equivalent runtime test.
- `docs/TEST.md` for the new runtime v2 document load coverage.

Run:

- `./tools/test.sh`
