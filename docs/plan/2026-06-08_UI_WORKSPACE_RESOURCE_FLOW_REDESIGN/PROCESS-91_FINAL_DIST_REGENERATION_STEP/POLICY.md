# PROCESS-91 Final Dist Regeneration Step Policy

Date: 2026-06-08

## Decisions

- Use the existing `tools/package_addon.sh` for committed package artifacts.
- Verify the committed manifest against a fresh temporary package manifest.
- Record the package run in review proof.
- Do not add committed-dist freshness checks to `tools/test.sh`.

## Non-goals

- Do not change package contents policy unless the script fails.
- Do not add new mandatory tests.
- Do not publish or upload release artifacts.
