# SCREEN-24 UX

## User Goal

A project author uses Paint as the screen for the current brush and selected cell feedback. Internal tile coordinates and raw object/label ids are not normal authoring controls; missing assets point to the owning asset screen.

## Operation Steps

1. Open the Workspace `Paint` tab.
2. Choose a paint mode: terrain, overlay, object, or label.
3. See the current brush asset for that mode.
4. If the required asset is missing, follow a CTA to Catalog or Object/Label asset selection.
5. Paint cells using the selected catalog entry, object definition, or label definition.

## Adopted UX

- Paint owns brush state, selected cell summary, and last edit summary.
- Terrain / overlay brushes use catalog keys from the Catalog asset.
- Object brushes use selected Object Definitions.
- Label brushes use selected Label Definitions.
- Missing assets are visible state with owner-tab routing, not hidden fallbacks.

## Deferred UX

- A first-class Zone brush remains deferred because the current editor mode set has no zone edit mode.
- Rich visual brush cards and selected-cell preview presentation remain UI presentation follow-up.

## Removed UX

- Normal Paint UI exposing `source_id`, `atlas_coords`, raw object id, or raw label id as the main control.
- Numeric fallback as Paint completion proof.
