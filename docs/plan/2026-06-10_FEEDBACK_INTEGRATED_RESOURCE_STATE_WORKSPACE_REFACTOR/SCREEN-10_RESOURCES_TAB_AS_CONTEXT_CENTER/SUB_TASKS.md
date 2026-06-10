# SCREEN-10 Resources Tab as Context Center Sub Tasks

## Goal

Make Resources answer what selected HexTileMap, Level Document, dependencies, missing resources, source badges, and next actions are active without forcing users to inspect individual row details.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Add selected HexTileMap summary with visible node name/status | Adopt | Resources needs a top-level context answer; node path stays tooltip/debug detail. |
| B. Add required/shared/optional resource status counts | Adopt | Resource rows remain useful, but screen-level status makes readiness scannable. |
| C. Add source badge rows for Node / Document Dependency / Manual Override / Sample / Missing | Adopt | Roadmap explicitly requires badge visibility and explanation. |
| D. Add missing-resource next actions | Adopt | Completion requires clear actions beyond row controls. |
| E. Move Catalog editor controls into Resources | Reject | `SCREEN-20` owns Catalog control relocation. |
| F. Move Layer/export controls into Resources | Reject | `SCREEN-21` owns responsibility relocation. |
| G. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
