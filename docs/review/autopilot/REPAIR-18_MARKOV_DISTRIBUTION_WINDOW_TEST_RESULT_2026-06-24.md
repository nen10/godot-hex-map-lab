# REPAIR-18 Markov Distribution Window test result

Date: 2026-06-24

Focused tests:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair17_18_test_generation_graph.log --path . --script res://tests/test_generation_graph.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair17_18_test_build_graph_canvas.log --path . --script res://tests/test_build_graph_canvas.gd
```

Result: pass.

Standard suite:

```sh
TEST_JOBS=4 ./tools/test.sh
```

Result: pass. Run id `20260624-044658-56029`.
