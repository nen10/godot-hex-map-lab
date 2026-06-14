# UI-METRIC-02 Implementation Plan

## Scope

- Add `tools/ui_static_audit.py`.
- Detect suspicious buttons without `pressed.connect`, forbidden placeholder button text, visible debug/raw/path label patterns, generic ResourcePicker patterns, and tab constructor without ScrollContainer suspicion.
- Document the command in `docs/TEST.md`.
- Run the audit command, run standard verification, and write proof docs.
- Update queue status, dependency sweep, proof log, and current pointer.

## Target Files

- `tools/ui_static_audit.py`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-02_STATIC_UI_AUDIT/`
- `docs/review/autopilot/UI-METRIC-02_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-02_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-02` RUNNING and create plan docs.
- Implement static audit script.
- Document audit command.
- Run `python3 tools/ui_static_audit.py`.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Mark `UI-METRIC-02` COMPLETE, keep/promote dependency-satisfied tasks, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| UI contract categories | Tool misses required detection class. | Script categories and self-review acceptance table. |
| Current source tree | Heuristics crash on GDScript syntax. | Run `python3 tools/ui_static_audit.py`. |
| Standard repo verification | New tool/docs should not break existing package/tests. | `./tools/test.sh`. |
| Future P0 gate | Tool cannot be made failing later. | `--strict` option. |

## Test Path

- `python3 tools/ui_static_audit.py`
- `./tools/test.sh`

## Planned Completion Criteria

- Suspicious buttons without pressed connection are detected.
- Forbidden button text is detected.
- Visible debug label patterns are detected.
- Generic ResourcePicker patterns are detected.
- Tab constructor without ScrollContainer suspicion is detected.
- `docs/TEST.md` documents the command.
