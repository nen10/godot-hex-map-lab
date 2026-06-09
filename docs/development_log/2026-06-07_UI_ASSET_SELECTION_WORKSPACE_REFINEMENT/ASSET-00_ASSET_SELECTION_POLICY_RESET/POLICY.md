# ASSET-00 Policy

## Adopted Decisions

- `sample-only prototype` means an editor-facing feature can be demonstrated with bundled sample assets but does not yet support arbitrary project assets in the normal workflow.
- `No sample-only completion` means sample preset success is not valid completion proof for production editor UX.
- Sample/package integrity tasks may test bundled samples directly, but feature-screen completion must prove project-asset selection or unconfigured-state behavior separately.
- Headless UI tests must target user-goal state such as selected resource, missing asset status, validation issue, or workspace context. They must not preserve a sample-only button or old widget shape as the product contract.
- Analog tests remain deferred during this CLEAN UI refinement roadmap unless the user explicitly asks for them.

## Rejected Decisions

- Do not make sample assets the default just to avoid empty UI.
- Do not treat fixed paths, raw text, numeric fallback, or compatibility wording as specifications for the asset selection workflow.
- Do not require human approval between plan creation and implementation for this queue.

## Boundary

- Policy documents define completion criteria and test design.
- Process documents define when the autopilot loop applies the criteria.
- Roadmap and queue documents define the current task breakdown and proof status.
- Later implementation tasks will create concrete asset-slot models, workspace context, and screen-specific controls.

## Breaking Change Rationale

The addon is unpublished, and the active roadmap explicitly prioritizes game-development UX over preserving old sample-driven or test-convenient flows. Reclassifying sample-only behavior as prototype behavior is therefore allowed and required.
