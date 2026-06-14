# EXPORT-NEXT-10 UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Process-only package build (`tools/package_addon.sh`, manual release path) | Stable workflow boundaries, predictable scope, less UI confusion in authoring tab order | Low operational surprise | Low | adopt | Aligns with existing policy and keeps Export focused on Runtime Handoff.
| B. Export tab package-build control | Direct one-click packaging from editor | High | High | reject | Breaks task taxonomy, encourages false distribution expectations, and conflicts with manual release checks.

## Experience scope (adopted)

- Export screen should remain a Runtime Handoff task: choose level document, optional Export Profile, destination, then run handoff.
- Export screen should continue to explain clearly what it does not do (document save, package build, debug report).
- Packaging must remain process-facing: run from terminal/CI check flow and documented in `docs/manual/MANUAL_PACKAGE.md`.
- Process-only boundaries should be surfaced in manual and UI contract docs rather than editor controls.

## What is explicitly not added

- No package zip/create button in Export.
- No upload/public release action in Export.
- No package artifact status row in normal Export workflow result UI.
- No `package` or `upload` path control inside Export tab action set.
