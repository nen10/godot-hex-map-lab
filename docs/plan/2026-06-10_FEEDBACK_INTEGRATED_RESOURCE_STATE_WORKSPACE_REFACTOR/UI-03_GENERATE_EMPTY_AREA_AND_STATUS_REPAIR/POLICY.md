# UI-03 Policy

## Adopted Decisions

- Generate result state is normal UI because it answers the user's workflow question.
- Raw generation snapshots and metadata remain debug/detail content.
- Blocked state may use empty-state wording; unblocked state should not reserve an unexplained blank area.
- Reload is valid only when it clearly means "re-read this source file".

## Rejected Decisions

- Do not hide working generation parameter, progress, preview, apply, or output controls.
- Do not convert file paths into primary visible labels.
- Do not treat bundled samples as production completion proof.
- Do not add new analog tests for CLEAN UI.

## Boundaries

- `HexMapWorkspace` owns Generate screen snapshot composition.
- `HexMapGenDock` owns run, output target, save, and mapdata source UI state.
- Tests assert state contracts and visible control purpose, not pixel layout.
