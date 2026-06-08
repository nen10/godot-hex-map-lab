# UIR-00 UX

## User Goal

Adopt the first-impression feedback as binding roadmap policy before more UI work starts. A game developer evaluating the workspace should not be told that a feature is complete merely because an API path or sample-only path works.

## Operation Steps

1. Read the active roadmap and queue before selecting implementation work.
2. Treat UI first impression as completion evidence for workspace tasks.
3. Keep bundled samples as learning and duplicate-to-project sources.
4. Require production paths to use user-selected or user-created project assets, or show a visible unconfigured state.
5. Keep committed `dist` freshness as a final process step, not a per-task test gate.

## Adopted UX

- UI completion includes whether the screen tells the developer what to do next.
- Sample candidates may be visible for learning, preview, or duplication, but are not silently selected as execution sources.
- Missing project resources are visible unconfigured states instead of hidden sample fallbacks.
- Dist regeneration happens after the UI roadmap stabilizes.

## Retained UX

- Headless tests remain useful for state contracts and workflow transitions.
- Manual first-impression checklists may be created later as lightweight review notes.

## Removed or Deferred UX

- Sample-only success is not production feature completion.
- A passing headless API test is not enough to complete a UI task.
- New analog tests remain deferred during CLEAN UI work unless the user explicitly asks for them.
- Per-task committed `dist` freshness checks are deferred to the final packaging task.

## Existing UX Interference

Older tests or docs that preserve path text, raw JSON, numeric fallback, migration wording, or silent sample defaults must yield to the active roadmap unless the roadmap explicitly keeps them.
