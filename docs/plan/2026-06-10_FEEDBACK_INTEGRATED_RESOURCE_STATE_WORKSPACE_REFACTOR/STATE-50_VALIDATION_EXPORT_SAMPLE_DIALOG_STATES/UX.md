# STATE-50 UX

## User Goal

Workspace workflows should explain whether validation has run, whether export can run, whether sample learning is inactive/available/applied, and whether a dialog is waiting for user input or has completed.

## Operation Steps

1. User opens Validate and sees whether validation is not run, running, clean, warning, error, selected, or focused.
2. User opens Export and sees whether destination/profile/document setup makes export blocked, ready, running, exported, or failed.
3. User opens Settings / sample learning and sees whether sample learning is off, available, duplicated to project, or a sample source was explicitly selected.
4. User triggers a dialog-backed action and the dialog state moves closed -> opening -> waiting_user -> committed or cancelled.

## Adopted UX

- State ids and ViewState fields are the public contract for these lifecycle surfaces.
- Existing visible screens may continue to look mostly the same, but their snapshots should expose lifecycle state.
- Disabled or blocked operations should have state-derived reason text.

## Deferred UX

- Validate issue navigator refinement is deferred to `SCREEN-23`.
- Export purpose screen redesign is deferred to `SCREEN-25`.
- Settings label simplification is deferred to `UI-02`.
- Root dispatcher/reducer integration is deferred to `STATE-60`.
