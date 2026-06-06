# GAME-01 Self Review 2026-06-07

## Scope Reviewed

- `addons/hex_map_kit/core/hex_movement_profile.gd`
- `addons/hex_map_kit/adapter/hex_movement_profile_resource.gd`
- `addons/hex_map_kit/adapter/hex_gameplay_layer_data.gd`
- `tests/test_hex_core.gd`
- `tests/test_hex_adapter.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-06_GAME-01_MOVEMENT_PROFILE_RESOURCE/`

## Acceptance Check

| Requirement | Evidence | Status |
|---|---|---|
| Movement profile defines passability | `tests/test_hex_core.gd` asserts default floors pass, default walls block, and walls can be configured passable. | pass |
| Movement profile defines costs | Core tests assert default, wall, catalog-key, and tag cost behavior. | pass |
| Movement profile defines blocker keys | Core and adapter tests assert catalog/object blocker keys and blocking tags produce blocked states. | pass |
| Default behavior exists | `HexMovementProfile` defaults to floor cost `1.0`, passable floors, and blocked walls with blocker key `wall`. | pass |
| Resource wrapper exists | `HexMovementProfileResource` roundtrip test saves/loads profile id, display name, costs, wall defaults, and blocker keys. | pass |
| Gameplay layer data exists | `HexGameplayLayerData` tests extract wall blockers, catalog cost tags, catalog blocking tags, and object blocker keys. | pass |
| Test path updated | `docs/TEST.md` includes movement profile and gameplay layer data coverage. | pass |

## Test Proof

`./tools/test.sh` passed on Godot `v4.6.2.stable.official.71f334935`.

Result artifact: `docs/review/autopilot/GAME-01_TEST_RESULT_2026-06-07.md`

## Repair Classification

- `repair-now`: none remaining.
- Repaired during task: gameplay fixture now uses typed terrain assignments so catalog keys are visible to v2 document extraction.
- `follow-up-ready`: none added by this review. Weighted path/range remains queued as `GAME-02`.
- `known-env-failure`: none.
- `accepted-risk`: object blockers are keyed by object id only until object database v2 lands.
- `manual-optional`: none.
