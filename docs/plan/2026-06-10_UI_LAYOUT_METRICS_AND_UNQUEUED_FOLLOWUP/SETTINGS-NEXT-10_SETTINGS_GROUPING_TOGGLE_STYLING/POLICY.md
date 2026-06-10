# SETTINGS-NEXT-10 Policy

## Scope

SETTINGS-NEXT-10 is a Settings tab presentation task. It may add grouping metadata, mounted group labels, and tooltip-backed checkbox state. It must not change production resource ownership.

## Requirements

- Settings snapshot exposes Sample Learning, Debug, Project Defaults, and UI Preferences groups.
- Boolean preference controls report CheckBox/toggle style and non-empty tooltip detail.
- Sample Learning remains opt-in and never silently satisfies production asset selection.
- Debug numeric fallback remains isolated in Settings.
- Resources remains owner of Movement Profile and other production asset defaults.

## Fallback / Defer Ledger

| item | disposition | rationale |
|---|---|---|
| Sample detail drawer | defer | Existing `SAMPLE-NEXT-10`. |
| Production asset selectors in Settings | reject | Violates current resource ownership policy. |
| Visible boolean text summaries | reject | Checkboxes/toggles are the user-facing boolean state. |

## Test Policy

- Extend the existing Settings/sample workflow test.
- Assert mounted/snapshot grouping and tooltip-backed controls.
- Run `./tools/test.sh`.
