# TAB-56 Policy

Task: `TAB-56_EXPORT_TAB_PURPOSE_REDESIGN`

Rules:

- Active Export means runtime handoff: Level Document to `HexMapResource`.
- Export destination must be chosen through Save As/FileDialog flow.
- Unsupported Data Export, Package Build, and Debug Report exports must be hidden or explicitly classified outside the active export action set.
- Sample destinations remain unavailable.
- Export Profile remains optional until a concrete profile schema is defined.

Completion evidence:

- `tests/test_editor_plugin.gd` verifies purpose, output type, source/target, hidden unsupported modes, and runtime handoff result.
- `docs/TEST.md` records headless coverage.
- `./tools/test.sh` passes.
