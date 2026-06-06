# QA-01 Policy

## Decisions

- Generation QA uses the existing document validation engine instead of a generator-specific rule fork.
- The generated result is converted to a v2 document snapshot so later seed promotion can reuse the same validation boundary.
- Automatic target apply remains available, but validation capture happens before apply/promotion.
- Failure is represented by stored validation result counts and `passed=false`; it does not require blocking all current editor apply behavior in this task.
- Normal generation status text remains compact. Detailed validation issue data belongs in debug/report and test-facing accessors.

## Compatibility

- Existing `HexMapResource` and `HexOverlayResource` save behavior is unchanged.
- Existing debug report validation summary remains present and becomes backed by the stored generation QA result when available.
- Catalogless numeric fallback is not treated as a QA-01 specification path.

## Test Policy

- Add headless editor tests under `tests/test_editor_plugin.gd`.
- Update `docs/TEST.md` because the editor plugin Test path gains generation QA coverage.
- Final completion proof requires `./tools/test.sh`.
