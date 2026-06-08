# UIR-00 Policy

## Adopted Decisions

- UI first impression outranks headless API availability for workspace UI completion.
- Bundled samples are learning, preview, and duplicate-to-project assets.
- Bundled samples are not production execution fallbacks for Generate, Paint, Validate, QA, or Export.
- Production feature completion requires arbitrary project asset selection or a visible missing/validation state.
- Committed `dist` freshness is handled by `PROCESS-91`; it is not added to `./tools/test.sh` as a normal task gate.

## Rejected Decisions

- Do not preserve sample fallback as a convenience default.
- Do not treat sample preset success as completion proof for production UI.
- Do not preserve old UI tests when they lock in confusing widget shape or legacy text.
- Do not add new analog tests during this CLEAN UI roadmap unless the user explicitly requests them.

## Breaking Change Rationale

The addon is unpublished, and the roadmap is explicitly UX-first. Removing silent sample fallback, path-text-driven flows, and test-shaped UI is acceptable when it makes the editor workflow clearer for actual project asset work.

## Resource / API / UI Boundary

- Resource/API behavior should expose typed project assets and validation states.
- UI should present compact, purposeful controls and explain missing resources without substituting samples.
- Tests should verify user-visible workflow state rather than private widget structure.

## Task-Local Decisions

This task updates project-level policy and queue proof only. Feature-specific resource ownership, tab layout, sample duplication, and export terminology remain in later scheduled tasks.
