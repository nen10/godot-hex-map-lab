# NODE-20 Test Result 2026-06-10

Command:

```sh
./tools/test.sh
```

Result: PASS

Coverage:

- `tests/test_editor_plugin.gd` verifies selected node and internal display layer resolution.
- The selected node test verifies Level Document read and dependency hydration from the selected document.
- Workspace writeback tests verify node-owned exports and all shared dependency slots.

Notes:

- Godot emitted known macOS certificate warnings documented in `docs/TEST.md`; they did not fail the run.
