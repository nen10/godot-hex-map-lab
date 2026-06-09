# CLEAN-50 Headless Editor Test Destruction Pass UX

## Goal

Headless editor tests should stop preserving old UI wiring as product requirements. They should protect clean user-facing state transitions and leave room for the upcoming document header, catalog screen, object palette, and harmful UI deletion tasks.

## Test Contract

- Tests may verify that resource/file workflows produce selected documents, selected import resources, saved destinations, validation rows, generated data, and target apply results.
- Tests should not require editable path `LineEdit` controls, target atlas path fields, or numeric fallback controls to exist.
- Tests that still use temporary helper methods may do so as implementation scaffolding, but assertions should be about state and output rather than private node existence.

## Non-Goals

- CLEAN-50 does not delete product UI controls.
- CLEAN-33 owns actual harmful UI removal.
- CLEAN-21/CLEAN-22/CLEAN-23 own replacement screens and richer clean UI tests.
