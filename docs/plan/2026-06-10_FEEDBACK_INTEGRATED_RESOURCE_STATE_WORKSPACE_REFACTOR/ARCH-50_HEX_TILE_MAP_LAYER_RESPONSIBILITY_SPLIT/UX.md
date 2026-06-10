# ARCH-50 UX

## User Goal

Runtime and editor users can keep using `HexTileMapLayer` as a convenient scene node, while its internals move toward a coordinator that delegates resource binding and document apply preparation.

## Operation Steps

1. Assign a `HexMapResource` to `hex_map`.
2. The resource binding helper prepares orientation, map data, and runtime snapshot.
3. Assign or load a `HexMapDocumentResource`.
4. The document apply helper prepares a duplicated document and runtime map resource.
5. `HexTileMapLayer` coordinates scene layers, display redraw, payload markers, and existing runtime queries.

## Adopted UX

- Existing assignment and helper APIs keep working.
- Document apply and resource binding are represented as separate helper sources.
- A responsibility snapshot explains `HexTileMapLayer` as coordinator.

## Deferred UX

- Gameplay query and debug overlay extraction are deferred.
- Object layer rendering remains through the existing `HexObjectLayerAdapter`.

## Existing UX Interference

- Tests rely on direct `HexTileMapLayer` runtime helpers; those APIs must continue to pass unchanged.
