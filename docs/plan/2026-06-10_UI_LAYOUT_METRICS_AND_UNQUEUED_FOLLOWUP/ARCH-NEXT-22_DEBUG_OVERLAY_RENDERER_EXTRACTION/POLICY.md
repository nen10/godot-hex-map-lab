## Scope Boundary

- `HexTileMapLayer` keeps: gameplay state, public API, map/object/overlay tile application, and object marker delegation.
- `HexDebugOverlayRenderer` owns: all immediate-mode debug overlay draw operations and no map mutation.
- Object marker calls continue through `HexObjectLayerRenderer` unchanged.

## Null Safety

- Overlay entry must be null-safe when map or callables are missing.
- Invalid issue cells from validation input are skipped.
- Missing color/data entries in range/highlight dictionaries are ignored or defaulted.

## Constraints

- No change to the `Current recommended next task` pointer in the shared queue.
- No other task status changes beyond `ARCH-NEXT-22`.
- No gameplay rendering behavior changes outside `HexTileMapLayer` overlay orchestration.
