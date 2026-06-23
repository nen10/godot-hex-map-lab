# REPAIR-16 Region Filter node typing redesign test result

Date: 2026-06-24
Branch: `autopilot/ui`

## Focused test

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair16_canvas.log --path . --script res://tests/test_build_graph_canvas.gd
```

Result: pass.

## Probe (verified editor typing fact)

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair16_probe.log --path . --script res://tools/probe_region_filter_connection_typing.gd
```

Shows the legacy `region_filter` still maps overlay(3) output against a terrain(1) input
(`port_type_ids_match_editor_connectable=false`), which the new typed nodes fix.

## Standard suite

```sh
TEST_JOBS=4 ./tools/test.sh
```

Result: pass. Run id `20260624-041801-44801`.

Known non-fatal macOS certificate warnings appeared during Godot startup.
