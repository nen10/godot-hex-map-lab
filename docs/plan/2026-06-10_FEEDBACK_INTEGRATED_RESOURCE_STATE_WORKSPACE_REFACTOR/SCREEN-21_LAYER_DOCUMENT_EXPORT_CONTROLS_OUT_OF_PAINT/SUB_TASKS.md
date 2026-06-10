# SCREEN-21 Layer Document Export Controls Out of Paint Sub Tasks

## Goal

Move Layer Stack, Level Document, and Runtime Handoff export workflow ownership out of Paint and into Layers, Resources, and Export while preserving Paint's active target/document context.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Resources owns document save/dependency/dirty state | Adopt | Resources already has Level Document and dependency source-badge context. |
| B. Layers owns Layer Stack role/template/create/apply/clear state | Adopt | Layers already exposes role rows and action availability. |
| C. Export owns destination, output type, and handoff run state | Adopt | Export already has destination dialog and export workflow state. |
| D. Paint keeps active document/target summary for editing readiness | Adopt | Paint needs context for whether a brush can apply edits. |
| E. Paint exposes document/layer/export management controls as normal UI | Reject | These controls are non-paint responsibilities and weaken first impression. |
| F. Remove EditTool helper methods immediately | Reject | Existing workspace tabs still call helper methods until component extraction. |
| G. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
