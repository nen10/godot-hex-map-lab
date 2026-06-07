# CLEAN-31 Self Review

Date: 2026-06-07
Task: CLEAN-31 Workspace / tab model decision

## Acceptance

- `docs/review/roadmap/EDITOR_WORKSPACE_MODEL_DECISION_2026-06-07.md` compares two-dock, workspace dock, and main screen options.
- The selected model is one `Hex Map Workspace` dock with tabs: Document, Generate, Paint, Catalog, Layers, Validate, QA, and Export.
- The decision uses UX criteria: document-centered work, discoverability, Godot editor compatibility, and narrow-width behavior.
- CLEAN-32 has clear component-extraction guidance based on UX responsibility, not file size.

## Verification

- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- `git diff --check` PASS.

## Review Notes

- No product code was changed in this task.
- The decision keeps the Godot viewport/Inspector/Scene context by choosing a dock rather than a main screen.
- `repair-now`: none.

## Residual Risk

- The selected workspace model still needs implementation in CLEAN-32 and cleanup in CLEAN-33.
