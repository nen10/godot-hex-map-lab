# Decision: Package Build UI — Process-only

Task: `EXPORT-NEXT-10`
Date: 2026-06-14
Decider: orchestrator (Opus), ratifying the executor's option analysis.

## Question

Should addon package build live in the editor Export UI, or remain process-only?

## Options

| option | summary | decision |
|---|---|---|
| A. Process-only | Package build stays `tools/package_addon.sh` (+ `--check` in tests); Export tab is runtime-handoff only. | **Adopt** |
| B. Editor Export affordance | Add a package-build / zip / upload control to the Export tab. | Reject |

## Decision

**Process-only (Option A).** The Export tab remains a Runtime Handoff surface and
does not build, zip, or upload addon packages. Packaging stays a CLI/process step.

## Rationale

- Existing policy already owns this boundary: `AGENTS.md` and `ROADMAP.md` §2 state
  public package upload is not auto-queued, and `dist` freshness is a final-process
  step, not a normal test gate. Option B would contradict standing policy.
- The Export tab's task is runtime handoff (level document → destination resource).
  A distribution/packaging control there blurs the task taxonomy and harms the
  editor's first impression.
- Packaging is already well served by `tools/package_addon.sh` (build + `--check`),
  documented in `docs/manual/MANUAL_PACKAGE.md` and exercised by `tools/test.sh`.

## Consequences

- No editor work is queued for package build. `PROC-NEXT-90` (final dist
  regeneration) remains the process owner.
- `MANUAL_PACKAGE.md` records the editor-UI boundary so the absence of a package
  button in Export is intentional, not a gap.
- If a future roadmap explicitly wants in-editor packaging, it must re-open this
  decision with a scoped task; it is not implied by the current Export work.
