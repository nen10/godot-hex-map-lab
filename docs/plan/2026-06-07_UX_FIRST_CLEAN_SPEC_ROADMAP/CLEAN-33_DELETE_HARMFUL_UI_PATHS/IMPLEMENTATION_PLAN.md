# CLEAN-33 Implementation Plan

1. Mark CLEAN-33 `RUNNING` in the queue.
2. Hide/demote Generate numeric fallback controls and manual apply from normal UI.
3. Make remaining path text status read-only where it is still displayed.
4. Update tests to assert the clean normal UI contract.
5. Update docs/manual wording around Apply Layer and fallback text.
6. Run `./tools/test.sh`, self-review, queue update, and commit.
