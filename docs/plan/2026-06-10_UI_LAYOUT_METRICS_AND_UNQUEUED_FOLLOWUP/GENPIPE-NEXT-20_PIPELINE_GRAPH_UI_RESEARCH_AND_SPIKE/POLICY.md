# GENPIPE-NEXT-20 Policy

## Scope

GENPIPE-NEXT-20 records the product decision for pipeline graph UI after `HexGenerationResultResource` exists. It may add decision/research docs and test documentation. It must not ship an unscoped graph UI.

## Requirements

- Compare Resource pass, linear pipeline, and node graph options.
- Explicitly scope or reject pass graph UI.
- Tie the decision to current Generate/QA candidate Resource flows.
- Run `./tools/test.sh` even though the task is documentation-oriented.

## Fallback / Defer Ledger

| item | disposition | rationale |
|---|---|---|
| Full node graph editor | reject | No current generation workflow needs arbitrary node editing. |
| Linear pipeline implementation | defer | Can be queued later if UI review asks for visible step sequence. |
| Resource result inspector | policy-scoped | Future UI can expose `HexGenerationResultResource.scope_snapshot()` as result detail without graph editing. |

## Test Policy

- Decision proof is the primary artifact.
- Standard regression gate remains `./tools/test.sh`.
- No new analog test is created.
