# LAYOUT-10 Policy

## Adopted Decisions

- A workspace tab is scroll-capable only when its `TabContainer` page root is a `ScrollContainer`.
- Embedded component scroll is useful but does not satisfy the workspace-level contract by itself.
- The scroll implementation must not change the tab registry, component ids, or asset slot ids.
- Headless tests should verify the scroll contract through public workspace readback helpers.

## Rejected Decisions

- Do not solve cramped rows by hiding controls in this task.
- Do not rename or regroup tabs in this task.
- Do not assert private node paths in tests.

## Resource / API / UI Boundary

- UI change: tab pages become scroll roots with vertical content boxes.
- API/readback change: workspace exposes whether a tab has a scroll root.
- Tests verify registry stability plus scroll presence.

## Task-Local Decisions

`ScrollContainer.horizontal_scroll_mode` is disabled for tab roots. Future row compaction handles horizontal pressure rather than allowing sideways scrolling.
