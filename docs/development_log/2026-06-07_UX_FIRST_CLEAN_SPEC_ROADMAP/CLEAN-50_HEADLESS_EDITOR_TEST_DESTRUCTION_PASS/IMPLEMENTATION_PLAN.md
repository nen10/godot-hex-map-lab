# CLEAN-50 Implementation Plan

1. Mark CLEAN-50 `RUNNING` in the queue.
2. Remove editor smoke assertions that require old path or numeric fallback controls by private member name.
3. Rewrite remaining assertion messages around clean state transitions where the test still has value.
4. Update `docs/TEST.md` so the editor test overview no longer describes obsolete controls as the contract.
5. Run `./tools/test.sh`.
6. Self-review, repair `repair-now` issues, update queue, and commit.
