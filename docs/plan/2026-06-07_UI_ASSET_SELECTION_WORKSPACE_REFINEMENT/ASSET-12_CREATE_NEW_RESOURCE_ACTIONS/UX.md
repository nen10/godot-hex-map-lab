# ASSET-12 UX

## User Goal

When an asset slot is missing a required project resource, the user can create a new project resource through the slot instead of hunting for a separate setup command.

## Operation Steps

1. A slot exposes `Create New...` when the screen allows new resources.
2. The create action opens a `.tres` Save As dialog with a resource-specific default file name.
3. After the user selects a path, the corresponding empty project Resource is saved.
4. The created Resource becomes the current asset in the workspace asset context.

## Adopted UX

- Create-new produces project Resources only.
- Sample assets are not copied, assigned, or mixed into the created project Resource.
- The action is reusable from any asset slot and does not depend on private widget names.

## Deferred UX

- Full screen placement of the create action is deferred to tab migration and screen tasks.
- Sample duplication remains a separate `SAMPLE-11` workflow.
