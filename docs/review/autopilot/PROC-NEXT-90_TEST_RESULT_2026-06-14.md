# PROC-NEXT-90 Test Result 2026-06-14

Task: `PROC-NEXT-90` Final dist regeneration

## Commands

| command | result | notes |
|---|---|---|
| `tools/package_addon.sh` | PASS | Regenerated `dist/hex_map_kit-0.3.0.manifest.txt` and `dist/hex_map_kit-0.3.0.zip`. |
| `./tools/test.sh` | PASS | Standard package check and headless Godot suite passed. |
| `cmp -s dist/hex_map_kit-0.3.0.manifest.txt .godot_user/package-check/20260614-225204-74545/hex_map_kit-0.3.0.manifest.txt` | PASS | Committed manifest matches package-check output. |
| `cmp -s dist/hex_map_kit-0.3.0.zip .godot_user/package-check/20260614-225204-74545/hex_map_kit-0.3.0.zip` | PASS | Committed zip matches package-check output. |

## Package Artifacts

- Manifest: `dist/hex_map_kit-0.3.0.manifest.txt`
- Zip: `dist/hex_map_kit-0.3.0.zip`
- Package-check manifest: `.godot_user/package-check/20260614-225204-74545/hex_map_kit-0.3.0.manifest.txt`
- Package-check zip: `.godot_user/package-check/20260614-225204-74545/hex_map_kit-0.3.0.zip`
- Manifest path count: `218`
- Zip size: `528297` bytes

## UI Metrics

- Report: `.godot_user/ui-metrics/20260614-225204-74511/workspace_layout_metrics.md`
- `total_p0_failures`: `0`
- `total_p1_issues`: `0`

## Notes

- Godot emitted the known macOS CA certificate `ret != noErr` messages documented in `docs/TEST.md`; tests exited successfully.
- Dist freshness remains a final process proof and was not added to the normal test gate.
