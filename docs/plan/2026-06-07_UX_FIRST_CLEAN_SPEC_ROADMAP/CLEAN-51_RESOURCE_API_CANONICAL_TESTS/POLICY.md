# CLEAN-51 Policy

## Decisions

- Add focused assertions that state the canonical contract directly instead of relying only on broad historical tests.
- Keep path helper coverage where it proves supplemental load behavior, but Resource objects remain the first tested runtime path.
- Do not add migration or compatibility fixtures.

## Verification

- `tests/test_hex_adapter.gd` covers the canonical Resource/API contract.
- `tests/test_debug_scenes.gd` covers runtime query by `HexMapDocumentResource`.
- `./tools/test.sh` remains the completion test path.
