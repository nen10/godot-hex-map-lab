# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep compact severity/rule/destination text | low | medium | low | reject | The user cannot scan scope, target, or suggested fix. |
| B. Rich issue table with severity/domain/scope/target/suggestion/actions | high | low | medium | adopt | Matches the requested Validate table surface. |
| C. Add disabled or placeholder actions for all issues | low | high | medium | reject | Placeholder actions violate real-action policy. |
| D. Use existing issue selection as focus action | high | low | low | adopt | It already routes to the responsible workspace tab. |

## User Goal

The user should be able to scan validation issues by severity, domain, scope, target, and suggestion, then use only real available actions to focus the issue in the responsible screen.

## Adopted UX

- Validate exposes a structured issue table contract.
- Each issue row has severity, domain, scope, target, suggestion, destination, and available actions.
- The only per-issue action in this task is the existing focus/select route when a row has a real destination.
- Mounted issue text summarizes the same columns without raw JSON or path-primary output.

## Rejected / Deferred UX

- No fake row buttons.
- No raw validation issue dump as primary UI.
- No debug overlay renderer extraction in this task.
- No analog tests.

## Experience Steps

1. User runs validation.
2. Validate lists issue rows with severity/domain/scope/target/suggestion.
3. User selects a row with a focus action.
4. Workspace routes to Resources, Catalog, Layers, or Paint as appropriate.
5. Validate keeps sample mode off and does not inject sample assets.
