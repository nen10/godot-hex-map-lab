# CLEAN-31 Workspace / Tab Model Decision UX

## Goal

Choose the editor workspace model before component extraction, using user workflow criteria rather than file size.

## User Contract

- The chosen model keeps the map document as the center of work.
- Catalog, Layers, Validate, QA, Generate, Paint, Document, and Export have clear homes.
- The model avoids conflict with Godot's standard viewport, Inspector, FileSystem, and Scene docks.
- Narrow dock widths remain usable by putting dense workflows on separate tabs/screens.

## Non-Goals

- No product code is extracted in this task.
- CLEAN-32 owns component scripts and code movement.
- CLEAN-33 owns deletion of harmful legacy/debug paths.
