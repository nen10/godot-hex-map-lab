# ARCH-41 Screen Component Extraction By UX Role Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Add per-screen role scripts for Resources, Catalog, Layers, Validate, QA, Export, and Paint. | Adopt | These are the screens named in the roadmap and current first-impression work. |
| Route Workspace snapshots through screen role contracts. | Adopt | Tests can verify screen scripts map to tabs/workflows instead of relying on Workspace literals. |
| Route EditTool Paint non-paint ownership/delegation through Paint screen script. | Adopt | This directly reduces Paint's Catalog/Layer/Export/Document responsibility surface. |
| Move actual UI node construction out of Workspace. | Defer | That is a larger component extraction and risks broad churn; this slice extracts role contracts first. |
| Split `HexMapGenDock` internals. | Defer | Generate screen internals are not part of the accepted screen list and can be handled by later architecture work. |

## Scheduled Task

No follow-up task is scheduled from this slice. Larger UI node construction extraction remains out of scope for this queue item.
