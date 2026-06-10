# SCREEN-20 Catalog Controls Out of Paint Sub Tasks

## Goal

Move catalog detail/editing ownership out of Paint and into Catalog while preserving Paint's ability to choose and consume catalog keys as brush inputs.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Catalog owns entry list/detail/preview/status snapshot fields | Adopt | Catalog tab already has most data; expose ownership explicitly. |
| B. Catalog owns create/edit/validate action state | Adopt | Add visible state fields so these actions are no longer Paint-only evidence. |
| C. Paint hides catalog entry list/add/validate controls from normal UI | Adopt | Paint should consume catalog keys, not edit catalog details. |
| D. Paint keeps catalog key selectors for brush/default choices | Adopt | Brush selection belongs in Paint as long as it uses catalog keys, not raw metadata. |
| E. Remove EditTool catalog helper methods immediately | Reject | Existing tests and internal helpers can remain non-primary until component extraction. |
| F. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
