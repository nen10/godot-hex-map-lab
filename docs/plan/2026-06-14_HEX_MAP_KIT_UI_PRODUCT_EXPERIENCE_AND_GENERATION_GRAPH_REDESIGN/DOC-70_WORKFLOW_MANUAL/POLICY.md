# DOC-70 POLICY

## Adopted Decisions

- The manual starts from the work route: **Build graph -> Promote layer -> Paint -> Export handoff**.
- Resource setup is described as support for map semantics: Catalog vocabulary, Layer roles/writable source, Resources bindings.
- QA/Validate remain support/parked flows and are not required in the primary route.
- Samples stay learning/onboarding assets and must be duplicated into project resources before adaptation.

## Rejected Decisions

- Do not keep Resources as the first production route.
- Do not document Generate as the main tab name when the product route is Build.
- Do not use sample success, raw paths, raw JSON, or numeric tile ids as normal completion proof.

## Resource / API / UI Boundary

This task changes documentation only. It documents current implemented behavior and does not introduce a new UI/API contract.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| sample as production fallback | reject | samples are learning assets | none | docs review |
| Resources-first mirror route | reject | Resources is a support shelf | none | docs review |
| QA/Validate as main route | reject | active roadmap parks these tabs | none | docs review |

## Completion Criteria

- `MANUAL_WORKFLOW.md` gives the primary route in work-purpose order.
- `README.md` summary matches the primary route.
- Existing setup/API/reference information remains available.
- `./tools/test.sh` passes.
