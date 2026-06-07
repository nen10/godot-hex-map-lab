# ARCH-04 Document Inspector Component UX

Task: `ARCH-04`  
Created: 2026-06-07  
Status: COMPLETE

## Goal

Move document and validation summary presentation out of the large editor dock files into a reusable inspector component.

## Operation Steps

1. Edit Dock still shows the same document status, validation dashboard, and debug report behavior.
2. A document inspector component displays compact document and validation summary state.
3. Edit Dock uses the component for document/validation summary state while retaining document path, target, and action controls.
4. Generate Dock uses the same summary helper for validation debug summaries.
5. Headless tests verify the component and existing Edit/Generate validation behavior.

## Non-goals

- No validation rule changes.
- No validation dashboard issue-list redesign.
- No saved resource schema changes.
- No manual release or public package action.
