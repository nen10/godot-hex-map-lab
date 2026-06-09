# ASSET-11 Policy

## Adopted Decisions

- `HexMapWorkspaceAssetContext` is a Resource so it can later be saved, duplicated, and assigned through editor APIs.
- `HexMapEditorSessionState` owns the active context and emits context-specific change keys.
- `HexMapWorkspace`, `HexMapGenDock`, and `HexMapEditTool` expose the same context reference.
- Current Generate/Paint panels may still have sample fallback until `SAMPLE-10`, but selected project assets in context take precedence.

## Rejected Decisions

- Do not move UI controls between tabs in this task.
- Do not create hidden sample defaults in the context.
- Do not add analog tests for the clean UI queue.

## Boundary

- This task creates the shared context and proves panels can reference it.
- Later tasks build visible asset screens, sample settings, and no-sample completion tests on top of this context.
