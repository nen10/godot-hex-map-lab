# PROFILE-NEXT-11 Test Result

## Commands

- `./tools/test.sh`
- `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Failed to load script|Compilation failed" .godot_user/test-runs/20260614-231102-14068/logs`
- `python3 tools/verify_task.py --task PROFILE-NEXT-11 --head HEAD --queue docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Result

- `./tools/test.sh`: PASS
- Package check output:
  - `.godot_user/package-check/20260614-231102-14075/hex_map_kit-0.3.0.manifest.txt`
  - `.godot_user/package-check/20260614-231102-14075/hex_map_kit-0.3.0.zip`
- UI metric report: `.godot_user/ui-metrics/20260614-231102-14068/workspace_layout_metrics.md`
  - `total_p0_failures`: 0
  - `total_p1_issues`: 0
- Script/parse error scan: no matches.
- `verify_task.py`: ACCEPT, 0 fail / 4 warn.

## Focused Coverage

- `tests/test_hex_adapter.gd`: validation suite disabled-rule filtering, severity override, count refresh, and null profile regression.
- `tests/test_editor_generation.gd`: generation profile seed/shape/radius/terrain/connectivity drives generation snapshot and generated data.
- `tests/test_editor_output.gd`: export profile file extension and inclusion flags drive output context, dialog defaults, and export result payload.

## Notes

- Godot emitted the known macOS certificate `get_system_ca_certificates` warning during headless runs; it did not fail the suite.
- Existing warning-path tests emitted expected warning output for invalid adjacency/query fixtures.
- `verify_task.py` warnings are expected for this dynamic follow-up format: the helper's row parser does not populate `assigned-status` / plan target metadata for the non-table dynamic section, and it reports the orchestrator pointer moving from `PROFILE-NEXT-11` to `none`.
