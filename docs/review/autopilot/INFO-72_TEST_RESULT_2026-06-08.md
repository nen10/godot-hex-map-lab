# INFO-72 Test Result

Date: 2026-06-08

## Commands

- `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file /Users/nenten/Desktop/cosmos/projects/godot-hex-map-lab/.godot_user/info72/test_editor_plugin.log --path . --script res://tests/test_editor_plugin.gd`
- `./tools/test.sh`

## Result

- PASS: focused editor plugin suite.
- PASS: standard project suite.

## Notes

- Export tab assertions confirm Runtime Handoff is the only active visible output mode.
- Data Export, Package Build, and Debug Report remain classified but not visible Export-tab outputs.
- Godot emitted the existing macOS CA certificate message and expected warning-path validation messages.
