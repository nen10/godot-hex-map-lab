# ASSET-01 Policy

## Adopted Decisions

- Inventory rows must use the roadmap fields: `slot_id`, `screen/tab`, `current UI`, `required asset type`, `current sample dependency`, `current arbitrary selection path`, `missing/invalid validation`, `flow classification`, and `cleanup task id`.
- `project_asset_selection` means the current UI can select or create a user project Resource/path through a Godot picker/dialog or typed Resource selector, not just consume a bundled sample.
- Sample preset, target atlas preset, sample catalog key, distribution preset, and object scene sample paths must be explicitly classified.
- Raw/path/debug controls remain visible in inventory even when they are acceptable as temporary debug/support routes.

## Rejected Decisions

- Do not classify a slot as complete just because the sample catalog or sample atlas can make it work.
- Do not remove or rewrite UI in this inventory task.
- Do not create a new analog test to validate the inventory.

## Boundary

- This task produces review documentation and queue proof.
- Later tasks implement the AssetSlot model, workspace context, screen migration, sample separation, and cleanup work.
