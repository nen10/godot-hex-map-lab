# CLEANUP-31 Policy

## Rules

- Raw text fields must not be visible in normal Paint authoring for the target fields.
- Existing raw payload controls may remain hidden as internal/debug synchronization if tests or helper APIs still need them.
- Object variant and spawn condition use enum selectors, with selected Object Definition metadata able to provide project-specific options.
- Object property key/value editing stays schema-driven through typed controls.
- Tests must assert the normal UI model, not only private widget presence.

## Acceptance Mapping

- Overlay item key: option selector visible, raw text hidden.
- Label ID: definition tree visible, raw id hidden.
- Object variant and spawn: option selectors visible, raw text hidden.
- Properties: typed property editor visible, raw JSON/table hidden.
