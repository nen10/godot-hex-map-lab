# RES-11 Document Dependency Hydration Sub Tasks

## Goal

Selected Level Document dependencies become the Workspace shared resource context without selecting bundled samples or hiding missing dependencies.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| Hydrate shared resources from `HexMapDocumentDependencyService` into `HexMapWorkspaceAssetContext` | Adopt | This is the core roadmap value and keeps all tabs on the same context. |
| Track source metadata in `HexMapWorkspaceAssetContext` | Adopt | Slot controls need a stable `Document Dependency` badge after panel sync. |
| Let manual project selections supersede dependency-derived resources | Adopt | A user can test or correct a project asset without changing the document dependency immediately. |
| Automatically fill missing dependencies from bundled samples | Reject | Roadmap explicitly says missing dependency stays missing; samples are learning assets. |
| Write hydrated shared resources back into document dependencies | Reject for this task | RES-11 is hydration only; shared writeback is part of later node/binding work. |

## Scheduled Task

No scheduled task is required. The adopted scope satisfies RES-11 without splitting.
