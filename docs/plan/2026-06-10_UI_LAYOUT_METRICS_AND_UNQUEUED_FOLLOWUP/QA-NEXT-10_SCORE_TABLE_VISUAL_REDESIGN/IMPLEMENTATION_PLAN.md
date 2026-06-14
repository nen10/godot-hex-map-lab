# Implementation Plan

## Scope

Add a richer QA scored table contract and mounted score table widget so seed candidates can be compared by rank, seed, score, validation status, selected state, preview availability, and promotion state.

## Target Files

- `addons/hex_map_kit/editor/hex_map_qa_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Extend QA Seed Lab panel with a mounted score table tree.
2. Add scored table row helpers in `HexMapWorkspace`.
3. Expose scored table columns, rows, row text, selected row index, promoted row index, and mounted table proof in QA snapshots.
4. Update QA Seed Lab refresh logic to populate the mounted tree and rich text.
5. Extend editor tests for score columns, validation text, selected row state, preview state, promotion state, and mounted table proof.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| New score formula | defer | Presentation task only. |
| Per-row thumbnail Controls | defer | Existing row preview payloads and selected thumbnail are already available. |
| Per-row promote buttons | reject | Existing selected-row promotion path remains the real action. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Score row payload | Table omits generated preview/validation fields. | QA editor test inspects scored table rows. |
| Selection | Table does not mark selected seed. | Test selects row and checks selected state/index. |
| Promotion | Table does not mark promoted document. | Test promotes selected row and checks promotion state. |
| Mounted UI | Table remains snapshot-only. | Test checks mounted score tree row count and mounted row text. |
| UI metrics | Table creates layout warnings. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `QA-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- QA snapshot exposes scored table rows and columns.
- Mounted QA table renders row count and rich row text after batch run.
- Selected and promoted seed states are visible in scored table rows.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
