# LD2-05 Editor Load Save Policy

作成日: 2026-06-07
Queue task: `LD2-05`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| v1 compatibility | Load v1 documents by migrating to v2 where editor code needs typed fields. | Users should not lose existing saved resources. |
| v2 preservation | Save/export from v2-aware editor paths must preserve typed resources. | LD2 schema work is only useful if editor roundtrips it. |
| Scope | Keep changes to existing document load/save helpers and tests. | Avoid coupling LD2-05 to catalog, validation UI, or layer-stack work. |
| Failure behavior | Missing or invalid selected resources should use the existing warning/status style. | Preserve current editor feedback patterns. |

## Test Policy

Update:

- `tests/test_editor_plugin.gd` for v2 document load/save or import/export behavior.
- `docs/TEST.md` for the new editor coverage.

Run:

- `./tools/test.sh`
