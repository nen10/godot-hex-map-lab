# NODE-21 Policy: Selected HexTileMap Auto-Binding

## Scope

This task makes selected-node context first-class in editor session state and the Workspace.

## Rules

- The selected HexTileMap node is the active Workspace target when auto-link is enabled.
- Auto-link defaults to enabled for new editor session state.
- No selected HexTileMap node is a normal, visible state, not an error or hidden diagnostic.
- The UI text for the empty state is exactly `No HexTileMap selected`.
- Manual Link button behavior is not part of the normal flow for this task.
- Resource write-back from Workspace controls is deferred to `NODE-23`; this task may expose selected-node context required by that work.

## Classification

The user-facing roadmap name `HexTileMap` maps to the current addon node class `HexTileMapLayer`.

## Test Policy

Tests should cover session state, Workspace visible context, and selection-update hooks through deterministic editor APIs. Do not add analog tests for this CLEAN UI task.
