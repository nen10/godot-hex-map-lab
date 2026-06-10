# ARCH-41 UX

## User Goal

Each Workspace tab should correspond to a clear user task, and Paint should be a paint surface rather than a place where Catalog, Layer, Export, or Document management is carried.

## Operation Steps

1. Open a Workspace tab.
2. The screen contract identifies its tab, workflow owner, and user task.
3. Paint shows brush/cell/viewport responsibilities.
4. Paint delegates Catalog, Resources, Layers, Export, and Validate ownership to their screens.

## Adopted UX

- Screen role scripts are named after user tasks, not line-count boundaries.
- Workspace snapshots expose the screen role source for Resources, Catalog, Layers, Validate, QA, Export, and Paint.
- EditTool Paint workspace snapshot uses the Paint screen role contract for delegated ownership.

## Deferred UX

- Physical UI node construction remains in existing files for now.
- Generate/Settings role extraction is deferred because this queue item names the Resource-centric task screens and Paint.

## Existing UX Interference

- Existing screen snapshots and tests rely on current fields; new role metadata must be additive.
