# REPAIR-14 Graph Canvas Edge Delete test result

Date: 2026-06-24
Branch: `autopilot/ui`

## Focused test

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair14_canvas.log --path . --script res://tests/test_build_graph_canvas.gd
```

Result: pass.

## Standard suite

```sh
TEST_JOBS=4 ./tools/test.sh
```

Result: pass.

Run id:

```text
20260624-024316-3036
```

Known non-fatal macOS certificate warnings appeared during Godot startup.
