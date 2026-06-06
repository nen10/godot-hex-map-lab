# ARCH-01 Editor Session State UX

作成日: 2026-06-07
Queue task: `ARCH-01`

## Goal

Generate Dock and Edit Dock can share the current target/document session state through a small editor-facing object instead of relying only on duplicated local fields. Existing target auto behavior must remain stable.

## Operation Steps

1. Editor session object stores selected target layer, current document, document path, import/export paths, and last source/reason metadata as needed.
2. Edit Dock can publish and consume target/document/path state.
3. Generate Dock can publish selected/generated target state without depending on Edit Dock internals.
4. Tests prove the state object and dock integration do not break existing auto-target behavior.

## Maintained UX

- Current Edit Dock target auto resolution remains unchanged.
- Current Generate Dock target selection remains unchanged.
- No new visible controls are required for this task.

## Non-Goals

- No catalog selector UI.
- No Generate Dock seed promotion.
- No large split of Generate Dock evaluation logic.
