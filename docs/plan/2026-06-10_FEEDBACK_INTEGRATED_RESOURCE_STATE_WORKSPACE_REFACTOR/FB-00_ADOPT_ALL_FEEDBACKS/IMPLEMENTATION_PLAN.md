# FB-00 Implementation Plan

## Scope

- Confirm the feedback-integrated roadmap and queue are present and aligned.
- Create task planning files including `SUB_TASKS.md`.
- Run the standard verification command.
- Write self-review and test result.
- Update queue status, dependency sweep, current pointer, and proof log.
- Commit the completed task without including unrelated dirty files.

## Change Targets

- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/FB-00_ADOPT_ALL_FEEDBACKS/`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/FB-00_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/FB-00_TEST_RESULT_2026-06-10.md`

## Steps

1. Mark `FB-00` as `RUNNING`.
2. Add `SUB_TASKS.md`, `UX.md`, `POLICY.md`, and `IMPLEMENTATION_PLAN.md`.
3. Verify roadmap/queue adoption content by reading and targeted search.
4. Run `./tools/test.sh`.
5. Write test result and self-review.
6. Mark `FB-00` complete and promote dependency successors.
7. Update current pointer and proof log.
8. Commit the completed task.

## Deferred Steps

- Do not change editor code in this task.
- Do not regenerate `dist`.
- Do not create analog tests.
- Do not repair FileDialog or no-op controls until `FB-01` / `FB-02`.

## Test Path

```sh
./tools/test.sh
```

If Godot is missing, record `BLOCKED_BY_TEST_ENV` instead of marking implementation complete.

## Docs Update

No global docs update is expected. The task-specific plan, review, test result, and queue proof are the documentation deliverables.

## Completion Checklist

- `ROADMAP.md` exists and names the 4 feedback sources.
- Priority source order is explicit.
- Analog test deferral is explicit.
- `dist` final-process-only rule is explicit.
- Queue contains the required operation references and task table.
- Queue proof log records this task.
- Next READY task is clear.
