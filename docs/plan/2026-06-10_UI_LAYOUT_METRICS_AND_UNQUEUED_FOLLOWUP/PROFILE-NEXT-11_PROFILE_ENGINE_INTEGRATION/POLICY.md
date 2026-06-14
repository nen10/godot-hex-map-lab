# PROFILE-NEXT-11 Policy

## Adopted Decisions

- Validation Suite integration lives in `HexMapDocumentValidator` so all validation callers share the same rule filtering and severity override behavior.
- Workspace and Generate validation option builders pass the selected Validation Rule Suite only when one is explicitly selected.
- Generation Profile integration overlays selected profile options onto generation snapshots; snapshot generation remains the execution boundary.
- Export Profile integration affects export context/result metadata and inclusion behavior while keeping runtime handoff as the only active export implementation.

## Rejected Decisions

- Do not auto-select bundled sample or preset profiles.
- Do not add compatibility/migration paths for old profile shapes.
- Do not add active data/package/debug export implementations.
- Do not treat profile screen exposure alone as completion.

## Resource / API / UI Boundary

- Resource helpers (`rule_enabled()`, `rule_severity()`, `generation_options()`, `export_options()`) are the canonical API.
- Editor UI supplies selected project Resources through `HexMapWorkspaceAssetContext`.
- Engine paths consume dictionaries derived from profile Resources; they do not read UI widgets directly when a profile is selected.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Missing profile optional state | keep | Profiles are optional behavior controls, not required defaults. | Product policy makes profiles mandatory. | Null-profile regression tests. |
| Sample/preset auto-injection | reject | Would convert learning assets into production defaults. | none | Existing sample separation tests plus new null-profile tests. |
| Unsupported export modes | reject | Current roadmap keeps package/data/debug export outside active normal Export UI. | New roadmap scopes those exports. | Export profile result tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| No Validation Suite selected | Validator reports the same issues and severities as before. | Optional profile changes default validation. | Adapter null-profile regression. |
| Validation Suite selected | Disabled rules are dropped and severity overrides are applied before counts update. | Counts become stale or issue filtering is partial. | Adapter suite test. |
| Generation Profile selected | Snapshot seed/shape/terrain/connectivity come from `generation_options()`. | UI widget values silently override explicit profile. | Editor generation test. |
| No Generation Profile selected | Snapshot keeps current UI/default values. | Defaults change unexpectedly. | Existing generation tests. |
| Export Profile selected | Export result exposes selected output type/file extension/inclusion flags. | Profile remains display-only. | Editor export test. |
| No Export Profile selected | Existing runtime handoff export remains available. | Optional profile blocks export. | Existing export test path. |
