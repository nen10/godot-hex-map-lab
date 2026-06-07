# VAL-04 Implementation Plan

## Scope

Add validation rule matrix fixtures, update test docs, run full proof, self-review, queue proof, and commit.

## Steps

1. Add `tests/test_hex_adapter.gd` rule matrix coverage for every accepted `VAL-01` rule.
2. Use both `_assert_has_issue()` and `_assert_no_issue()` for each rule.
3. Keep fixtures small and rule-specific.
4. Update `docs/TEST.md`.
5. Run `./tools/test.sh`; repair failures in-task.
6. Write self-review/test-result docs, update queue proof, and commit.
