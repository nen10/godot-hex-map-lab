# UI-01 UX

## User Goal

Users should scan Resource rows quickly, see which project resources are ready/missing/problematic, and use tooltips for type/path/source details without row text becoming noisy.

## Operation Steps

1. Open any Workspace tab with Resource rows.
2. Scan role labels and status swatches.
3. Hover status or picker for type/path/source/purpose details.
4. Select or create a project resource.
5. Use explicit sample action only when learning from a sample source.

## Adopted UX

- Row header shows role label and compact status swatch.
- Row body shows resource picker and real actions.
- Status words such as `OK`, `Missing`, `Optional`, `Warn`, and `Invalid` are not normal visible row text.
- Resource paths and source details remain in tooltip/detail/debug surfaces.
- Hidden detail labels may exist for programmatic detail expansion, but there is no visible placeholder Details button.

## Maintained UX

- EditorResourcePicker remains the main selection control.
- Create New remains available where supported.
- Learn With Sample remains explicit and opt-in.
- State snapshots still expose `status_text` for debug/test contracts; visible layout does not show it.

## Deferred UX

- Exact branded icon art is deferred; this task uses a colored status swatch keyed by `status_icon`.
- Screen-level movement of controls remains in SCREEN tasks.
- Settings-specific boolean/debug cleanup remains in UI-02.
