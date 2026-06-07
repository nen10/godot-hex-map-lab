# PKG-01 Examples UX

Task: `PKG-01`  
Created: 2026-06-07  
Status: RUNNING

## Goal

Provide package-facing examples that show how a user starts from a runtime document query and from an editor-authored v2 document workflow without depending on editor plugin classes at runtime.

## Operation Steps

1. Open `examples/basic_runtime/` to find a minimal runtime scene/script that loads a document path and returns path/range query data.
2. Open `examples/editor_workflow/` to find a sample authoring document builder and workflow notes for Generate/Edit/Validate/Runtime handoff.
3. Run the debug-scene test path to confirm the example scripts and scenes load with runtime-safe dependencies.

## Non-goals

- No public release upload.
- No addon zip packaging; that remains `PKG-03`.
- No full API manual split; that remains `PKG-02`.

