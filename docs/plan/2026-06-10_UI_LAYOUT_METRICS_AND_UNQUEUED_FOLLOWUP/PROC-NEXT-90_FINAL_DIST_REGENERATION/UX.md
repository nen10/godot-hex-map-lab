# PROC-NEXT-90 UX

## User Goal

Maintainers should have committed addon package artifacts that match the current `addons/hex_map_kit/` tree at the end of the roadmap, without making every normal task responsible for committed `dist` freshness.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Final process packaging step | high | low | low | adopt | Produces inspectable release artifacts at the roadmap boundary. |
| Package-check only, no committed `dist` update | medium | medium | low | reject | Acceptance explicitly requires committed `dist/` freshness for this final task. |
| Per-task committed-dist gate | low | medium | medium | reject | Creates noisy binary churn and contradicts the roadmap boundary. |
| Editor UI package-build button | low | high | high | reject | `EXPORT-NEXT-10` decided package build remains process-only, not normal editor Export UI. |

## Experience Steps

1. Run `tools/package_addon.sh` to regenerate committed `dist/`.
2. Run `./tools/test.sh` so the standard package check and headless suite pass against the same tree.
3. Compare committed `dist` output with the deterministic package-check output from `.godot_user/package-check/`.
4. Record the package artifact paths and diff result in self-review/test-result docs.

## Adopted UX

- Packaging remains a maintainer process step.
- The committed manifest and zip are inspectable proof artifacts.
- Standard test runs continue to write temporary package-check output only.

## Rejected UX

- No public upload flow is added.
- No editor-facing package build affordance is added.
- No recurring committed-dist freshness warning is added to normal task testing.
