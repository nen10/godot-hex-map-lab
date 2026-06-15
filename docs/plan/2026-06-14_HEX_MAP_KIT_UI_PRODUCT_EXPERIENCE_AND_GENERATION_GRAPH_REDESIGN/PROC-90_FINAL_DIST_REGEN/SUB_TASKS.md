# PROC-90 SUB_TASKS

## Complexity

Class: C1
Reason:
- Final process step only.
- Uses existing package script.
- No product behavior or UI design change.

Required artifacts:
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`
- self-review and proof log

## Task Resolution

Regenerate committed `dist/` artifacts from the current addon tree after roadmap docs/code completion.

## Scope

含む:
- Run `tools/package_addon.sh`.
- Verify the committed manifest/zip are produced from the current addon tree.
- Run `./tools/test.sh` as final standard verification.

含まない:
- Public upload or release signing.
- Changing addon version.
- Adding dist freshness to normal per-task test gates.

## Scheduled Task Audit

なし。
