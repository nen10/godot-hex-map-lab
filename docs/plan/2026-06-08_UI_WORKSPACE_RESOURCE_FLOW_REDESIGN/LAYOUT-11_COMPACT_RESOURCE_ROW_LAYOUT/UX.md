# LAYOUT-11 UX

## User Goal

Make Resource rows scannable in narrow editor docks. A developer should see the resource name, picker, and short status first; details like path, required type, and validation messages should not dominate the default view.

## Operation Steps

1. Open a workspace tab with asset rows.
2. Scan each row by title, resource picker, and status.
3. Hover the row/status or open details when the required type, selected path, or validation message is needed.
4. Keep Create/Open/Clear/Validate behavior unchanged until the action-button task.

## Adopted UX

- Default row shape is compact: title, picker, status, details affordance.
- Long current path, type, and validation messages move to tooltip/details.
- Missing state remains visible as a short status.
- Existing action buttons remain below the compact row for now.

## Retained UX

- Resource picker selection behavior remains unchanged.
- Create New and Clear behavior remains unchanged.
- Slot state snapshot contract remains unchanged.

## Deferred UX

- Removing redundant buttons is deferred to `ASSET-31`.
- Wiring or deleting remaining actions is deferred to `ASSET-32`.
- Purpose tooltips for every resource type are deferred to `INFO-70`.

## Existing UX Interference

The old control displayed `Current:`, `Type:`, `Status:`, and messages as always-visible labels. This made every slot multi-line even when nothing was selected. Those labels move behind details/tooltip.
