# GENPIPE-80 Generation Pipeline State Concept Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Carry forward the 2026-06-08 generation pipeline graph review and result model notes. | Adopt | They already reject premature graph UI and define Profile / Preview / Result / Level Document boundaries. |
| Re-check current Generate, overlay, QA, and document snapshot paths. | Adopt | The new concept must describe current `_current_data`, `_current_overlay_data`, seed rows, and document metadata accurately. |
| Compare Resource pass, linear pipeline, and node graph options. | Adopt | The roadmap requires candidate comparison before backlog implementation. |
| Define final document vs intermediate map roles. | Adopt | Resource/API cleanup depends on a stable authoring boundary. |
| Implement `GenerationResultResource` or a node graph editor now. | Reject | `GENPIPE-80` is a design backlog task and should not add schema/UI surface yet. |

## Scheduled Task

No follow-up task is scheduled from this slice. Future implementation should begin with a concrete `GenerationResultResource` / replay API task before any graph UI task.
