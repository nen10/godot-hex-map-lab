# ASSET-30 UX

## User Goal

A developer choosing project assets from Workspace rows should see the exact Resource type expected by each slot before opening the picker, and the picker should prevent unrelated `Resource` choices wherever the slot has a concrete type.

## Operation Steps

1. Open Resources or a feature tab with project asset slots.
2. Inspect a slot row and tooltip to understand what asset type belongs there.
3. Open the picker and see a concrete Resource type filter, such as `HexMapDocumentResource` or `HexTileCatalogResource`, rather than generic `Resource`.
4. Pick a matching project asset.
5. If a slot intentionally accepts a flexible Resource, the slot explains why through its tooltip/snapshot.

## Adopted UX

- Typed slots use concrete Resource class filters.
- Slot tooltips state the expected type and purpose.
- Snapshot/test APIs expose the configured picker type so UI behavior is verifiable without relying on private node names.

## Rejected UX

- Generic `Resource` is not used for slots with a known concrete asset class.
- Type mismatch is not treated as a normal post-pick warning when the picker can prevent it.
- Long type explanations are not shown as row text in the compact UI.

## Existing UX Interference

- Some built-in profile slots currently store plain `Resource` values. They may stay flexible only if documented as preset/profile resources without a concrete class in the current addon.
