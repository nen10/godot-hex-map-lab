# UI-02 UX

## User Goal

Settings should read as explicit preferences and sample-learning controls, not as a debug dump of booleans and file paths.

## Operation Steps

1. Open Settings.
2. Toggle sample/debug options through CheckBoxes.
3. Review sample learning rows by label.
4. Hover rows/status for sample paths.
5. Duplicate sample Catalog to a project path when needed.
6. Use snapshots/debug report for raw paths and diagnostic payload.

## Adopted UX

- CheckBoxes communicate boolean state.
- Sample rows show sample names, not paths.
- Duplicate result status shows the outcome, not the output path.
- Tooltips/snapshots retain paths and diagnostic detail.
- Settings debug summary label is hidden; debug opt-ins remain explicit controls.

## Deferred UX

- Larger Settings grouping/toggle styling is deferred.
- Sample detail drawer is deferred unless a later task needs richer sample inspection.
