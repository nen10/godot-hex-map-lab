# LST-01 Policy

## Decisions

1. `HexLayerStackResource` and `HexLayerStackEntryResource` live in `addons/hex_map_kit/adapter/` as typed resources.
2. Role names are stable lowercase strings: `terrain`, `decoration`, `object`, `collision`, `navigation`, `overlay`, and `debug`.
3. Templates return resources instead of mutating `HexTileMapLayer`; `LST-02` will consume these templates for apply behavior.
4. Layer entries carry `layer_id`, display name, role, intended node name, order, z index, visibility, and metadata.
5. Template ordering follows draw/application intent: terrain, decoration, object, collision, navigation, overlay, debug.

## Compatibility

- `HexTileMapLayer` internal child layers remain unchanged.
- Existing runtime/editor display tests must continue to pass.
- No document migration is required in this task.

## Repair Criteria

- All seven roles are defined as constants and returned by the standard template.
- Minimal runtime template includes the roles needed by current runtime display plus debug.
- Resources save/load as typed resources.
- `./tools/test.sh` must pass.
