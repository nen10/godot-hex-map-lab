# P0-03 Test Baseline

作成日: 2026-06-07
Queue task: `P0-03`
Command: `./tools/test.sh`
Result: PASS

## Environment

| Item | Value |
| --- | --- |
| Godot version | `v4.6.2.stable.official.71f334935` |
| Test runner | `tools/test.sh` |
| Test jobs | default `TEST_JOBS=1` |
| Latest run directory | `.godot_user/test-runs/20260607-002420-88462` |
| Logs | `.godot_user/test-runs/20260607-002420-88462/logs/` |

`tools/test.sh` resolved a runnable Godot binary in the current environment and executed all configured scripts.

## Passing Scripts

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_debug_scenes.gd`

## Non-Fatal Output

Godot printed the known macOS system CA certificate message:

```text
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

`docs/TEST.md` documents this as non-fatal when the command exits successfully.

The editor tests emitted expected warning-path messages for invalid adjacency rules, missing source registry resources, empty placement mask query results, empty deductor floor query results, and missing overlay source stack. The test command still exited successfully.

## Baseline Classification

- `BLOCKED_BY_TEST_ENV`: no
- `known-env-failure`: none
- `implementation-regression`: none
- `test-expectation-wrong`: none
- `pre-existing`: none
- `repair-now`: none

## Consequence

`P0-03` can be marked `COMPLETE`. Implementation tasks depending on `P0-03` may proceed when their other dependencies are complete.
