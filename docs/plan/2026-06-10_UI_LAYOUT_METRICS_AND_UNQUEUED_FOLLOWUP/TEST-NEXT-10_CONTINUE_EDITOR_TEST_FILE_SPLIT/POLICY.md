## Adopted decisions

- Move each remaining feature-family test cluster from `test_editor_plugin.gd` into dedicated `tests/test_editor_<family>.gd` files.
- Preserve existing assertions exactly where possible and keep behavior unchanged.
- Keep `test_editor_plugin.gd` as cross-feature smoke (registration + top-level workspace + paint viewport handoff assertions).
- Keep shared constants, fake classes, and helper methods in `tests/test_editor_plugin_test_base.gd` to avoid repeated helper duplication.

## Rejected decisions

- Introducing any new private widget-shape expansion assertions.
- Changing resource contracts, widget internals, or sample-specific fallback behavior in tests.
- Keeping feature tests inside monolithic `test_editor_plugin.gd`.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Legacy monolithic editor assertions in `test_editor_plugin.gd` | remove (except smoke tests) | task requires split by feature family and smoke-level plugin runner | Never keep once family files own full remaining set | `./tools/test.sh` must run every new suite |
| Duplicate helper assertions between family files | avoid | increases drift risk and makes maintenance harder | Shared helpers in base remain single source | helper usage in moved families |
| Test-only duplication of private internals from widget nodes | avoid | violates no private widget shape expansion policy | No new private internals assertions added | static review |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| `test_editor_plugin.gd` _run sequence | only smoke calls remain and still includes cross-feature handoff assertions | accidental leakage of deep tests into smoke | `test_editor_plugin.gd` contains exactly two `_test_*` functions and one `_finish` path |
| Family test files | each moved function exists once in the same assertion form as source | missing or duplicated tests | function-name presence checks during migration |
| Shared output path helpers | `_test_resource_path`, `_test_resource_dir`, `_test_output_dir`, `_test_run_id` exist and behave consistently | temp output collisions/IO failures | base helper definitions and multiple family call sites |
| `tools/test.sh` suite list | includes all new family files | incomplete coverage if omitted | test run passes all listed files |
