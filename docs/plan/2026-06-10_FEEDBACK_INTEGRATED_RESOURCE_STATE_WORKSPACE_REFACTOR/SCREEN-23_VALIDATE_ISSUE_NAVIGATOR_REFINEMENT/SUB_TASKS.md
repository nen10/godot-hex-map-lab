# SCREEN-23 Validate Issue Navigator Refinement Sub Tasks

## Goal

Make Validate the workflow-level issue navigator with a run action, issue list, severity/scope/focus metadata, and tab/resource/cell navigation.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Validate owns workflow run action | Adopt | Slot-level Validate buttons are already absent; the screen needs explicit workflow action state. |
| B. Validate owns issue list/severity/scope/focus action state | Adopt | Existing issue rows already contain this data; expose it as screen contract. |
| C. Issue click routes to Resource/Catalog/Layers/Paint/Validate focus | Adopt | Existing selection navigation should be made explicit. |
| D. Paint-side validation dashboard remains normal UI | Reject | Validation workflow belongs in Validate; helper can remain hidden for internal tests until extraction. |
| E. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
