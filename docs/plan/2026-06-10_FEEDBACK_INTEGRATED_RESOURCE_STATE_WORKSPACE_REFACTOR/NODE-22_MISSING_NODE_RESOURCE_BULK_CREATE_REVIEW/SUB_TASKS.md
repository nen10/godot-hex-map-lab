# NODE-22 Missing Node Resource Bulk Create Review Sub Tasks

## Goal

Review the existing `Create Missing Resources` flow against the current node/document/dependency ownership model.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Keep bulk create for all missing resources | Reject | Shared project resources must not be silently created as node-owned outputs. |
| B. Keep bulk create only for node-owned unique resources | Adopt | Level Document and Layer Stack remain the selected node's missing unique resources. |
| C. Sync already selected shared resources into the created Level Document dependencies | Adopt | If the user has selected shared project resources, the newly created document should immediately match Workspace context. |
| D. Create placeholder shared resources during this flow | Reject | Shared resources require explicit create or select existing actions. |

## Scheduled Task

No scheduled task is required.
