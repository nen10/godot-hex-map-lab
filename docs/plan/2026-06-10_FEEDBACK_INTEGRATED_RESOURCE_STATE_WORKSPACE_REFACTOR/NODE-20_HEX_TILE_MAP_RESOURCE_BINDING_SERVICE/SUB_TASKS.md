# NODE-20 HexTileMap Resource Binding Service Sub Tasks

## Goal

Selected `HexTileMapLayer` binding should be handled by a service that reads node-owned resources, reads document dependencies, and writes Workspace selections back to the correct owner.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| Add `HexMapWorkspaceBindingService` for selection resolution, hydration, and writeback | Adopt | This is the roadmap target and reduces direct binding logic in `HexMapWorkspace`. |
| Move node-owned Level Document / Layer Stack read and write into the service | Adopt | These are selected-node exports and must remain node-owned. |
| Write shared Workspace resources into selected document dependencies | Adopt | RES-11 reads dependencies; NODE-20 closes the write side. |
| Redefine `HexTileMapLayer.hex_map` authoring role | Reject for this task | NODE-21 owns that decision. |
| Replace all Workspace state transition flags | Reject for this task | STATE tasks own the broader state machine. |

## Scheduled Task

No scheduled task is required. NODE-20 can complete by introducing the binding service and routing the existing Workspace paths through it.
