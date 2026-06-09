# SAMPLE-11 Policy

## Adopted Decisions

- Sample duplication is centralized in `HexMapSampleAssetDuplicator`.
- The helper rewrites duplicated catalog dependencies to project paths.
- Successful duplication assigns only the project catalog copy to workspace asset context.
- Tests verify dependency paths and absence of silent sample context assignment.

## Rejected Decisions

- Do not treat bundled sample catalog as a production default.
- Do not duplicate samples automatically when sample mode is enabled.
- Do not implement first-run CTA in this task.

## Boundary

- This task creates the duplication contract and Settings panel entry point.
- Later tasks can improve UX around conflict prompts and onboarding.
