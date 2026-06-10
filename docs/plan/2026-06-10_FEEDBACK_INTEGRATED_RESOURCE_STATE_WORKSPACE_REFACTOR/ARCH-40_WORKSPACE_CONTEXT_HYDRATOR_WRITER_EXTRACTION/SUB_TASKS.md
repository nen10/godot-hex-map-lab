# ARCH-40 Workspace Context Hydrator Writer Extraction Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Move writeback snapshot assembly from `HexMapWorkspace` into `HexMapWorkspaceBindingService`. | Adopt | The snapshot is domain state, not UI rendering. |
| Move shared dependency writeback loop/save orchestration into the service. | Adopt | Workspace should not manually walk dependency slots. |
| Mark hydration snapshots/results with service source and use service helpers from Workspace. | Adopt | This gives testable proof that hydration is service-owned. |
| Add a brand-new screen/component extraction layer. | Defer | Screen extraction belongs to `ARCH-41`. |
| Rewrite all asset context setters through a new dispatcher. | Defer | That would expand beyond this slice and risk unrelated UI behavior. |

## Scheduled Task

No follow-up task is scheduled from this slice. Remaining screen extraction is already covered by `ARCH-41`.
