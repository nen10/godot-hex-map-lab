# EXPORT-NEXT-10 Sub Tasks

## Complexity

Class: C2

Reason:
- The task is a UX/API boundary decision with two candidate options.
- No production code changes are expected, but decision scope has UX wording, workflow classification, and queue/proof updates.
- One review path exists and queue/process dependencies are stable.

Required artifacts:
- `SUB_TASKS.md` with option resolution and deferred item audit.
- `UX.md` with candidate matrix.
- `POLICY.md` with invariants and exclusion rules.
- `IMPLEMENTATION_PLAN.md` with proof/test plan.

## Task Resolution

| option | user goal | decision | reason |
|---|---|---|---|
| A. Keep package build as process-only (`tools/package_addon.sh` only) | Keep Export as Runtime Handoff task and keep production packaging explicit/manual | adopt | Existing policy requires process-owned package upload and committed `dist` freshness is handled outside normal test gate. |
| B. Add editor Export affordance for package build | Add faster distribution surface for users | reject | Contradicts current roadmap policy, increases confusion with runtime handoff, and leaks distribution concerns into production editor first-impression workflow. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Build packaging affordance inside Export UI | n/a | reject | This decision is recorded as complete in `EXPORT-NEXT-10`; queue moves to packaging process tasks (`DOC-NEXT-90` / `PROC-NEXT-90`) if needed.
| New packaging UI task split | none | reject | Rejecting this path keeps process ownership in `PROC-NEXT-90` and `MANUAL_PACKAGE.md` flow, not editor UX.
