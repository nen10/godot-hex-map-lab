# User goal

Split the remaining editor integration test suite into feature-family files so each suite keeps the same behavioral assertions while making suite ownership legible and reducing the monolith to a small smoke runner.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep one giant editor test file with all assertions | no test ownership | medium | low | reject | difficult to inspect and maintain feature-family behavior; fails split acceptance. |
| B. Keep only smoke tests in `test_editor_plugin.gd` and move remaining assertions to family suites | stronger ownership and faster navigation across map generation/palette/workspace issues | low | medium | adopt | preserves existing assertions and clarifies feature contracts. |
| C. Add temporary integration index file that dispatches to existing test files in `autoload` style | moderate | medium | reject | would be extra indirection and no direct benefit over plain test suite files. |

## Adopted experience

1. `test_editor_plugin.gd` becomes a compact workflow smoke test for plugin registration and cross-tab/workspace interactions.
2. Remaining families execute as standalone test scripts, each extending `test_editor_plugin_test_base.gd`.
3. Shared helper behavior remains in base helpers so each suite can still perform file-backed output assertions.
4. `tools/test.sh` executes all suites deterministically.

## UX explicitly adopted / rejected

- Adopted: family-based suite ownership matching workspace/map/generation/asset/etc responsibilities.
- Adopted: smoke-only root plugin suite.
- Rejected: introducing new private widget assertions or private internals dependencies.
- Deferred: any additional UX polish around test organization (out of scope for this task).
