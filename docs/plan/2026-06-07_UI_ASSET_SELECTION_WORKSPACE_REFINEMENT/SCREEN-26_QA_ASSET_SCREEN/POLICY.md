# SCREEN-26 Policy

## Adopted Decisions

- `SLOT_GENERATION_PROFILE` and `SLOT_VALIDATION_RULE_SUITE` are the QA screen's main project assets.
- Workspace QA helpers use the shared QA asset panel and context.
- Preset duplication creates project `.tres` Resources with `preset_source` metadata before selection.
- Score table context is state-level data: profile path/name and validation suite path/name.

## Rejected Decisions

- Do not silently use built-in distribution presets as selected project assets.
- Do not implement a full generation-profile schema in this task.
- Do not require sample assets for QA completion.

## Resource / API / UI Boundary

- `HexMapWorkspace` owns QA asset actions and score-table context.
- `HexMapGenDock` remains the generation batch runner.
- Future profile schema work can replace generic Resource metadata without changing the screen ownership contract.

## Task-Local Decisions

- Built-in preset ids are `balanced`, `sparse`, and `dense` for Generation Profile, and `standard` for Validation Rule Suite.
- Generic Resources are sufficient for profile/suite selection until dedicated resources exist.
