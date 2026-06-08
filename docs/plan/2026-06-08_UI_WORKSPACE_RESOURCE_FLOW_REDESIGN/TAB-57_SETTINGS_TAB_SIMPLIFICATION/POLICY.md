# TAB-57 Settings Tab Simplification Policy

Date: 2026-06-08

## Decisions

- Settings is not a production asset selection tab.
- Production resource slots live in Resources or the task-specific screen that owns the workflow.
- Movement Profile is a project resource and belongs with Resources as an optional project dependency.
- Debug numeric tile fallback stays explicit and isolated in Settings.
- Bundled samples stay learning / duplicate sources. They are not silent production inputs.

## Non-goals

- Do not add a sample execution fallback.
- Do not add a new analog test.
- Do not introduce a new Settings resource picker for production assets.
