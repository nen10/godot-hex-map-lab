## Complexity

Class: C4
Reason:
- Refactor scope spans all remaining editor integration tests and changes test runtime execution topology.
- Multiple states, UI families, and CI surfaces are impacted by moving ~100+ test cases into feature files.
- Queue/proof and process obligations include proof-log updates and test harness updates.

Required artifacts:
- Task resolution candidate matrix.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Fallback / Mirror Handling table.
- State / Invariant table.
- Dependency / test matrix.

### Task resolution candidate matrix

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Keep all integration tests in `test_editor_plugin.gd` and add no smoke split | preserve current test layout | reject | violates task scope and maintainability constraints in queue acceptance. |
| B. Split remaining tests by feature family into dedicated `test_editor_*.gd` files and reduce `test_editor_plugin.gd` to smoke tests | preserve behavior while reducing monolith size and making file ownership explicit | adopt | matches acceptance verbatim and keeps assertions unchanged. |
| C. Move only high-level tests and keep deep tests in a shared helper script | reduce file count without full split | reject | still leaves monolith-sized behavior and weakens family traceability. |
| D. Split by implementation subsystem folders only (`test_editor_generation*`, `test_editor_layout*`, etc.) | preserve family-ish ownership | reject | existing clusters already defined by families in task wording and would not match acceptance expectations. |

### Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Additional queue-only tests not tied to production changes | `ARCH-NEXT-21`, `ARCH-NEXT-22` | deferred | This is a test split refactor only; no production behavior changes requested in task. |
| New sample-only tests for plugin smoke flow | `TEST-NEXT-12` (not queued) | deferred | would be coverage debt outside this task boundary. |

### Adopted subtasks

| sub-task | scope | proof |
|---|---|---|
| `TEST-NEXT-10.01` | Move remaining `_test_*` functions into feature-family files (`workspace`, `map`, `generation`, `distribution`, `hex`, `asset`, `catalog`, `layer`, `object`, `paint`, `sample`, `document`, `validate`, `qa`, `output`) | family files execute the same assertions unchanged. |
| `TEST-NEXT-10.02` | Keep `test_editor_plugin.gd` as high-level workflow smoke with a small number of integration flows | Plugin retains UI handoff contract and smoke-level cross-feature assertions only. |
| `TEST-NEXT-10.03` | Share path/output helpers in `test_editor_plugin_test_base.gd` and register all new files in `tools/test.sh` | all moved tests run and resolve expected temp resources. |
| `TEST-NEXT-10.04` | Create task plan/review artifacts and queue proof updates | `IMPLEMENTATION_QUEUE.md` proof log and `*_TEST_RESULT` / `*_SELF_REVIEW` files include full task evidence. |
