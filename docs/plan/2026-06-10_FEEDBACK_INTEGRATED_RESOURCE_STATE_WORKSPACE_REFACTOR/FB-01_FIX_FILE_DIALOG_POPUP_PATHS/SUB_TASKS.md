# FB-01 Sub Tasks

## Task Resolution

task resolution:

- task candidate: centralize popup parent lifecycle
  - goal / UX: FileDialog を開く操作が、呼び出し元ごとの parent 操作に依存しない。
  - decision: adopt in this task.
  - summary: `HexMapEditorPathSelector.popup_dialog()` に parent attach contract を集約し、呼び出し側の直接 `add_child(dialog)` を削除する。
- task candidate: keep callback-based commit/cancel handling
  - goal / UX: headless test が実 popup に依存せず、file/dir selected handler を検証できる。
  - decision: adopt in this task.
  - summary: 既存の `file_selected` / `dir_selected` callback path は維持し、DialogState class は後続 state task へ送る。
- task candidate: move all project FileDialog creation to helper
  - goal / UX: Workspace / AssetSlot / Sample / Dist の dialog creation が同じ helper shape を使う。
  - decision: adopt for target files.
  - summary: Dist editor の direct `EditorFileDialog.new()` path を helper 経由へ寄せる。AssetSlot / Sample は既に popup helper を使っているため、contract test 対象にする。
- task candidate: implement full dialog state machine
  - goal / UX: closed/opening/waiting/committed/cancelled を状態として見えるようにする。
  - decision: defer to `STATE-50`.
  - summary: `FB-01` は lifecycle safety repair であり、state machine 実装は roadmap の state task で扱う。

## Scheduled Tasks

No new Scheduled task is added by this task.

Reason:

- Full dialog state modeling already belongs to `STATE-50_VALIDATION_EXPORT_SAMPLE_DIALOG_STATES`.
- The current acceptance can be completed by centralizing attach/popup behavior and preserving callback contracts.

## Completion Boundary

`FB-01` is complete when:

- Target FileDialog popup paths call the lifecycle helper instead of adding the dialog to a parent first.
- `HexMapEditorPathSelector` exposes a testable lifecycle snapshot/contract that does not require real popup interaction.
- Tests confirm the helper does not reparent an already attached dialog and that target popup call sites use the helper contract.
