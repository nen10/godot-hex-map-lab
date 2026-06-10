# STATE-50 Policy

## Adopted Decisions

- Validation, Export, Sample, and Dialog lifecycle states are separate data models with explicit `state_id`, `state_source`, and ViewState output.
- Workspace snapshots should include these state models so tests and later screens do not recombine private flags.
- Sample states must preserve the learning-source policy and must not make bundled samples production-ready defaults.
- Dialog states describe lifecycle and callback result; they do not require actual editor popups in headless tests.

## Rejected Decisions

- Do not move workflow controls between tabs in this task.
- Do not expose raw paths as normal state text beyond destination/resource identity already required by existing Export contracts.
- Do not add new analog tests.
- Do not replace the existing FileDialog helper unless state exposure reveals a direct lifecycle bug.

## Boundaries

- `HexMapWorkspace` owns Validation / Export / Sample workflow state context.
- `HexMapSampleSettingsPanel` owns sample settings operations and can expose sample state.
- `HexMapEditorPathSelector` owns dialog lifecycle snapshots.
- Later root dispatcher integration will consume these ViewStates rather than changing their meaning.
