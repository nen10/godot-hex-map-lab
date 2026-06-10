# ARCH-41 Policy

## Adopted Decisions

- A screen script maps one tab/workflow to one user task.
- Screen role extraction is justified by ownership and user task, not by file length.
- Paint must declare non-paint responsibilities as delegated and keep management visibility false.
- Workspace may still assemble detailed runtime snapshots, but ownership metadata comes from screen role scripts.

## Rejected Decisions

- Do not extract UI construction wholesale in this task.
- Do not move Catalog/Layer/Export/Document controls back into Paint.
- Do not add analog tests.

## Resource / API / UI Boundary

- Resource/API state remains in existing services and snapshots.
- Screen scripts provide user-task role contracts.
- Workspace and EditTool consume role contracts when presenting ownership.

## Compatibility

The addon is unpublished, so snapshot role metadata can be added directly.
