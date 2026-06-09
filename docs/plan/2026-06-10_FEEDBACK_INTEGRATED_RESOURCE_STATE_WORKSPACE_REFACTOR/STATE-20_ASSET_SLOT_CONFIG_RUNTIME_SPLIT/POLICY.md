# STATE-20 Policy

## Adopted Decisions

- Slot definition/config, runtime selection, validation result, sample availability, and operation result are separate state sections.
- ViewState is the only state shape the row control should use for visible status and action availability.
- Required missing, optional missing, selected project resource, selected sample warning, invalid type, and operation success/failure must be distinguishable.

## Rejected Decisions

- Do not preserve mixed status strings as the internal contract.
- Do not use sample availability as an implicit selected resource.
- Do not redesign visual row density in this task.

## Boundaries

- Resource/API: selected values remain real Resource references.
- UI: current labels/buttons may remain, but their content comes from ViewState.
- Tests: use headless state contract assertions and avoid private widget shape expansion.
