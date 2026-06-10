# NEXT-00 Policy

## Adopted Decisions

- Use a new roadmap directory for UI metric and unqueued follow-up work.
- Treat `UI_LAYOUT_METRIC_TEST_PROCESS_ROADMAP_2026-06-10.md` and `UNQUEUED_REQUIREMENTS_EXTRACT_2026-06-10.md` as source feedbacks.
- Queue process safeguards before large UI/architecture implementation.
- Queue UI metric contract/gates before future UI acceptance-sensitive work.
- Keep analog tests and public package upload outside this queue unless user policy changes.

## Rejected Decisions

- Do not reopen the completed Resource / State / Workspace refactor queue.
- Do not leave P0/P1 deferred requirements only in feedback prose.
- Do not add committed dist freshness to normal test gates.

## Invariants

- Sample Learning never becomes production source.
- Debug/path/raw/internal state stays outside normal UI.
- UI metric tests detect structural defects; they do not replace human aesthetic review.
- Each future deferred implementation item must have a queue id, a policy-deferred reason, or a ledger entry.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Manual Override source state | ledger | Explicit source state can look like fallback without owner/proof | none yet; `PROCESS-12` decides whether permanent | existing dependency hydration tests |
| Sample Learning source | ledger | Must stay learning/duplicate source, not production fallback | none; production source rules remain | sample mode OFF/ON tests |
| Debug/raw detail surface | ledger | Debug details are allowed in reports, forbidden in normal UI | normal UI contract and metric gates pass | UI metric future tests |
| Generation private mirrors | implementation task | Mirrors are transition debt, not final API | `STATE-NEXT-11` retires or documents mirrors | generation run state tests |

## Resource / API / UI Boundary

- This task is documentation/planning only.
- Resource/API/UI changes happen in later queue tasks.
- Test execution still uses `./tools/test.sh` for adoption proof.
