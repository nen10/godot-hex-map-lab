# SCREEN-24 Policy

## Adopted Decisions

- QA screen snapshots must report QA workflow ownership and visible Seed Lab surface state.
- Generation Profile use is part of the QA contract when a profile is selected.
- Score rows, selected seed, promote target, and promotion availability are first-class fields.
- The Level Document is the authoring source of truth for promoted QA results.
- Draft context text must distinguish Generate preview candidates from QA promotion.

## Rejected Decisions

- Do not treat generic Resource references as sufficient QA completion.
- Do not silently use bundled samples as the QA production path.
- Do not move promotion ownership back to Generate.
- Do not add a new analog test for this CLEAN UI slice.

## Resource / API / UI Boundary

- Resource: Generation Profile and Validation Rule Suite remain concrete profile Resources in workspace context.
- API: QA snapshot and Seed Lab context expose screen state needed by tests and UI renderers.
- UI: QA presents comparison and promotion; Generate remains candidate creation and preview.

## Compatibility

The addon is unpublished, so the screen contract may gain new fields without compatibility work.
