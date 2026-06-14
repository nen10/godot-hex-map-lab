# PROC-NEXT-90 Final Dist Regeneration Sub-Tasks

## Complexity

Class: C2
Reason:
- This is a final process/package artifact task with committed binary output and proof docs.
- It does not change product behavior, editor UI, or Resource/API contracts.
- The main decision boundary is keeping committed `dist` freshness outside normal per-task tests.

Required artifacts:
- Complexity header.
- Task resolution.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Fallback/mirror handling confirmation.

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Run `tools/package_addon.sh` into committed `dist/`. | Adopt | The queue acceptance requires final committed package artifacts matching the current addon tree. |
| Run `./tools/test.sh` after regeneration. | Adopt | Standard autopilot verification still applies and includes package `--check`. |
| Compare committed `dist` artifacts with the package-check artifacts from the passing test run. | Adopt | This proves the committed manifest/zip are the same deterministic package that the standard check produced. |
| Add a recurring committed-dist freshness gate to `tools/test.sh`. | Reject | Roadmap policy explicitly keeps dist freshness as this final packaging task, not a normal per-task gate. |
| Publish or upload the zip. | Reject | Public release distribution requires external release credentials and remains outside autopilot. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Recurring committed-dist freshness gate | none | explicit reject | Active roadmap keeps dist freshness outside normal `./tools/test.sh`. |
| Public package upload | none | policy-deferred | External release/publishing action requires human-owned credentials and is not an autopilot queue task. |

## Scheduled Task

No follow-up task is scheduled from this slice.
