# VAL-03 UX

## User Outcome

Debug reports should include compact validation proof so authors can copy one report and see whether the current document or generated map has validation issues.

## Report Behavior

- Edit Dock debug reports include validation summary and grouped issue rows.
- Generate Dock debug reports include validation summary for the current generated map state.
- Normal target/generation status labels remain compact and do not gain validation issue dumps.

## Non-Goals

- A richer validation rule fixture matrix remains queued as `VAL-04`.
- A shared document inspector component remains queued as `ARCH-04`.
