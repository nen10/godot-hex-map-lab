# SCREEN-24 UX

## User Goal

The user opens QA to compare generated seed candidates through a Generation Profile, see scored rows, select a seed, and promote that seed to the current Level Document with a clear draft boundary.

## Operation Steps

1. Open QA.
2. Confirm the Generation Profile and Validation Rule Suite context.
3. Run Seed Lab to generate a batch of candidate seeds.
4. Review score rows and the selected seed.
5. Promote the selected seed to the Level Document.
6. Confirm Resources now points to the promoted Level Document.

## Adopted UX

- QA owns the Seed Lab workflow label and state.
- Score table, selected seed, and promotion target are visible states even before rows exist.
- The source of truth is named as Level Document.
- The draft boundary is explained as candidate preview in Generate and selected promotion in QA.
- Generation Profile state is visible as a profile context, not a generic resource reference.

## Deferred UX

- Visual redesign of the scored table widget is deferred unless a later component extraction task touches QA layout.
- New analog testing is deferred during CLEAN UI work.

## Existing UX Interference

- Generate still previews a single candidate; QA compares batches. The screen contract must keep those responsibilities separated.
- Sample presets may duplicate project profiles, but sample mode is not completion proof for this task.
