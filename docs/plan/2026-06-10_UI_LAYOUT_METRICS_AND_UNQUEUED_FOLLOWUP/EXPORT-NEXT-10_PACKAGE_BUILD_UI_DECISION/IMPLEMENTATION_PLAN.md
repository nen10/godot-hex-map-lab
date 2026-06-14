# IMPLEMENTATION_PLAN.md — EXPORT-NEXT-10

## Scope

A product decision (depth: decision). No production code. Record the decision and
reflect it in the manual.

## Target Files

- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/EXPORT-NEXT-10_PACKAGE_BUILD_UI_DECISION/PACKAGE_BUILD_UI_DECISION.md` (decision record)
- `docs/manual/MANUAL_PACKAGE.md` (editor-UI boundary note)
- `docs/plan/.../IMPLEMENTATION_QUEUE.md` (EXPORT-NEXT-10 row + proof-log)

## Steps

1. Evaluate option A (process-only) vs option B (editor Export package-build UI).
2. Decide: process-only (option A), grounded in existing policy.
3. Record the decision doc; add an "Editor UI boundary" note to MANUAL_PACKAGE.md.
4. Run `./tools/test.sh` to confirm the docs change keeps the suite green.
5. Update queue status/proof; commit.

## Verification

- `./tools/test.sh` stays green (docs-only change; no test changes expected).
- No files under `addons/` or `tools/` modified.
