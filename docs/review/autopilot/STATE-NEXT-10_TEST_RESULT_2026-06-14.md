# STATE-NEXT-10 Test Result 2026-06-14

Task: `STATE-NEXT-10_ROOT_REDUCER_EVENT_MODEL`

## Command

```sh
./tools/test.sh
```

## Result

Pass.

## Output

- Run used package manifest: `.godot_user/package-check/20260614-102627-57397/hex_map_kit-0.3.0.manifest.txt`
- Run used package zip: `.godot_user/package-check/20260614-102627-57397/hex_map_kit-0.3.0.zip`
- Test file result: `tests/test_editor_plugin.gd: all tests passed`
- Full test suite status: all listed test scripts passed.
- Environment notes:
  - Non-fatal `get_system_ca_certificates` warnings are recurring and pre-existing.
  - Existing known warnings appear in `test_editor_plugin` generation scenarios (expected paths).

## Assertions Added for STATE-NEXT-10

- Verified dispatcher dispatch result includes:
  - `reducer_result`
  - `side_effects`
  - `ui_state_update`
  - `debug_report_proof`
  - existing envelope fields (`ok`, `error`, `event_id`, `payload`, `root_state`, `view_state`)
- Verified unknown events return typed failure (`ERR_INVALID_PARAMETER`) and preserve event_id.
- Verified null workspace paths return typed failures (`ERR_UNAVAILABLE` for null workspace).
- Verified sample/validation/export/validation-focus regressions still hold in view-state contracts.
