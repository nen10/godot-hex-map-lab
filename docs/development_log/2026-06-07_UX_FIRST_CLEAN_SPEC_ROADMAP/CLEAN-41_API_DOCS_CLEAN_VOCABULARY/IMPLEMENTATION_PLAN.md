# CLEAN-41 Implementation Plan

1. Mark CLEAN-41 `RUNNING` in the queue.
2. Update `docs/api/API_REFERENCE.md` so Resource object APIs and canonical vocabulary appear before path helpers.
3. Update `docs/manual/MANUAL_SCRIPTING.md`, `docs/manual/MANUAL_WORKFLOW.md`, and runtime example README files to use Resource-first runtime query examples.
4. Update runtime sample wrapper code and tests if path-first behavior is still the visible example contract.
5. Update `docs/TEST.md` if tests or coverage descriptions change.
6. Run `./tools/test.sh`, self-review, queue update, and commit.
