# GENPIPE-NEXT-10 Policy

## Scope

GENPIPE-NEXT-10 adds a Resource/API boundary for generated candidates. It may add a new Resource script, batch row fields, replay helpers, and QA/Generate snapshot fields. It must not implement graph UI or change generation algorithms.

## Requirements

- `HexGenerationResultResource` stores candidate scope: primary map, overlay map, candidate document, validation result/summary, preview, score, and source snapshot.
- Batch rows expose a result Resource and replay availability.
- Promotion uses the result Resource when present and writes result metadata to the promoted document.
- Tests cover Resource save/load, Generate replay, QA snapshot exposure, and promotion metadata.

## Fallback / Defer Ledger

| item | disposition | rationale |
|---|---|---|
| Pipeline graph UI | defer | `GENPIPE-NEXT-20` owns graph research/spike. |
| Profile behavior schema | defer | `PROFILE-NEXT-10` owns concrete profile behavior. |
| Replacing all row dictionaries | defer | Existing table rows remain the view model; result Resource becomes the durable candidate payload. |

## Test Policy

- Add adapter/resource tests for `HexGenerationResultResource` serialization and replay scope.
- Extend Generate/QA editor tests for result Resource row fields and promotion metadata.
- Run `./tools/test.sh`.
