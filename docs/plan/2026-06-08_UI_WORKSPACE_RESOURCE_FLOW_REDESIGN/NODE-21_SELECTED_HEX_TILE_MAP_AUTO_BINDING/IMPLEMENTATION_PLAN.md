# NODE-21 Implementation Plan

## Target

Implement selected HexTileMap auto-binding across editor session state, Workspace context display, and plugin selection integration.

## Steps

1. Add selected HexTileMap node and auto-link state to `HexMapEditorSessionState`.
2. Add a compact Workspace context surface that shows selected node state or `No HexTileMap selected`.
3. Add Workspace APIs for applying selected HexTileMap nodes from editor selection.
4. Connect the editor plugin's Scene Tree selection change signal to Workspace/session state where available.
5. Update editor tests for default auto-link, empty state, node selection, invalid selection, and resource context propagation.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Write autopilot self-review and test result.
9. Update queue and roadmap status/proof.

## Acceptance Mapping

- Node selection change updates Workspace context: plugin selection hook plus Workspace/session API tests.
- No selected node shows `No HexTileMap selected`: Workspace snapshot and label test.
- Auto-link default ON: session state test.
- Manual Link button no longer blocks the flow: no primary Link action is added; state is represented as status text.
