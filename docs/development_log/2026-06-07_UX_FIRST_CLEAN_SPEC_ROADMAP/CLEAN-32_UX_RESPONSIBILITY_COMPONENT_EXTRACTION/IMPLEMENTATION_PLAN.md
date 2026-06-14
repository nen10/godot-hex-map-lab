# CLEAN-32 Implementation Plan

1. Mark CLEAN-32 `RUNNING` in the queue.
2. Add `HexMapWorkspaceComponentRegistry` for tab/responsibility mapping.
3. Add `HexMapWorkspace` dock shell with Generate and Paint/Edit mounted as interim components.
4. Update `plugin.gd` to register the workspace dock and route viewport input through it.
5. Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
6. Run `./tools/test.sh`, self-review, queue update, and commit.
