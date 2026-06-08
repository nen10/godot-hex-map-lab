# TAB-56 UX

Task: `TAB-56_EXPORT_TAB_PURPOSE_REDESIGN`

The Export tab is a runtime handoff screen. It takes the current Level Document and writes a `HexMapResource` `.tres` for runtime/API use.

Primary screen:

1. State the Export purpose in one line.
2. Show the active output type: Runtime Handoff Resource.
3. Show the source: current Level Document.
4. Show the destination: user-selected project `.tres` path.
5. Keep unsupported exports out of active controls and classify them as backlog or process tasks.

Hidden/backlog classifications:

- Data Export / JSON: backlog.
- Package Build: developer process, not normal Export tab.
- Debug Report: diagnostic action in Paint/Generate, not production export output.

Non-goals:

- Do not add JSON/export graph formats in this task.
- Do not add package build buttons to the Export tab.
- Do not expose editable raw path text.
