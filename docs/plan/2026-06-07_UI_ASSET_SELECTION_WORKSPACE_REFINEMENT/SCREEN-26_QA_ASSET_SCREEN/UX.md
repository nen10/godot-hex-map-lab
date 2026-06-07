# SCREEN-26 UX

## User Goal

A project author runs Seed Lab / QA with selected project Generation Profile and Validation Rule Suite assets, and score rows clearly show which profile and suite were used.

## Operation Steps

1. Open the Workspace `QA` tab.
2. Create or select a project Generation Profile.
3. Create or select a project Validation Rule Suite.
4. Optionally duplicate a built-in preset to a project asset.
5. Run or inspect score table rows that include selected profile and suite context.

## Adopted UX

- Generation Profile and Validation Rule Suite are project asset slots.
- Built-in presets become project assets only through explicit duplicate-to-project actions.
- Score table context reports selected profile and validation suite names/paths.

## Deferred UX

- Full generation profile schema and validation-suite rule editing remain later resource design work.
- This task keeps profiles as Resource-backed assets with metadata sufficient for screen state and tests.

## Removed UX

- Treating built-in distribution presets as the QA completion proof.
- Hiding which profile/suite produced a score row.
