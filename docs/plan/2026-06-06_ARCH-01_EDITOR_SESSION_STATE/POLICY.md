# ARCH-01 Editor Session State Policy

作成日: 2026-06-07
Queue task: `ARCH-01`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Scope | Add a small shared session resource/script and narrow dock hooks. | Avoid a broad refactor before later feature tasks need it. |
| Ownership | Session state stores references and paths; docks keep their existing UI logic. | This reduces coupling without rewriting both docks. |
| Tests | Use headless editor tests for state propagation and existing target auto behavior. | Current test suite already covers dock behavior without UI runtime. |
| Compatibility | Existing public dock methods and target selection behavior must remain valid. | ARCH-01 is a companion refactor, not a UX rewrite. |

## Test Policy

Update:

- `tests/test_editor_plugin.gd` for shared session state and unchanged target auto behavior.
- `docs/TEST.md` for the new architecture coverage.

Run:

- `./tools/test.sh`
