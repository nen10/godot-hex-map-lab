# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep one long Generate stack | low | high | low | reject | Users cannot quickly distinguish configuration, preview, document apply, save, and performance state. |
| B. Use explicit work sections in one scroll surface | high | low | medium | adopt | Keeps familiar controls while making task boundaries visible. |
| C. Split Generate into multiple tabs | medium | medium | high | reject | Adds navigation cost and obscures the single generation workflow. |
| D. Put output/apply/save at the top only | medium | medium | low | reject | Output state matters, but inputs and performance state still need clear groups. |
| E. Add thumbnails now | high | medium | high | defer | Covered by `GEN-NEXT-11`; this task only reserves a preview section surface. |

## User Goal

The user should open Generate and immediately understand:

- where map/profile/source inputs are configured.
- what the current preview/result represents.
- whether output will stay preview-only or apply to the selected Level Document.
- how Save As differs from Apply to Document.
- whether generation or apply work is busy, cancellable, or idle.

## Adopted UX

- One scrollable Generate screen remains the working surface.
- Section labels and grouping separate:
  - Input.
  - Profile / Source.
  - Preview.
  - Apply / Save.
  - Performance.
- Output target status names Preview, Document, Save, and Target state in one visible line.
- Save and Apply actions stay near the output target state instead of appearing as unrelated controls.
- Progress and cancel state is a distinct Performance section.

## Rejected / Deferred UX

- No new map thumbnail rendering in this task.
- No split into a multi-tab Generate wizard.
- No raw generation snapshot, private flag names, sample path, or generic reload wording as primary UI.
- No sample-only preview completion.

## Experience Steps

1. User opens Generate and sees stable work sections instead of an undifferentiated stack.
2. User configures generator type, shape, size, seed, and profile/source controls in Input and Profile / Source.
3. User runs generation from the Input section and watches Performance for busy/cancel state.
4. User reads Preview state from the output summary without assuming the Level Document changed.
5. User intentionally chooses Apply to selected Document or Save As `.tres` from the Apply / Save section.
6. Heavy tile/update work is represented as Performance state, separate from preview-only readiness.
