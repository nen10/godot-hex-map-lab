# Debug Label Policy

## Principle

Debug information is available, but it is not the Workspace first impression. Normal UI should describe user tasks and state, while debug report surfaces preserve internal details for diagnosis.

## Normal UI

Allowed:

- short state labels,
- task purpose,
- readiness summary,
- selected resource role/name,
- visible next action,
- validation severity/count,
- export/generation result summary.

Not allowed:

- raw JSON,
- internal state dictionaries,
- private flag names,
- filepath as primary visible text,
- node path as primary visible text,
- numeric fallback/debug fallback as normal feature text,
- always-on boolean text such as `true/false` when the control state already communicates it.

## Tooltip / Detail

Allowed:

- filepath,
- resource type and filter reason,
- source badge explanation,
- longer blocked reason,
- validation rule id/fix detail,
- sample source path,
- recent destination path.

Tooltip/detail text must explain a user decision. If text only helps a maintainer inspect internals, it belongs in the debug report.

## Debug Report

Allowed:

- root state snapshot,
- screen ViewStates,
- raw validation/export/generation result payloads,
- node paths,
- resource paths,
- internal ids and event names,
- raw fallback/debug flags.

Debug report generation should use state snapshots. It must not require scraping visible labels or private widget structure.

## Settings

Settings may expose explicit debug opt-ins. It must not present debug payloads as regular status labels. UI-02 should convert redundant boolean text to checkbox/toggle state and move diagnostic payloads to debug report/copy flow.

## Generate

Generate may show technical run/progress/blocking information when it is directly required to run or understand generation. UI-03 must distinguish:

- visible run state and result destination,
- tooltip detail for block reasons and advanced parameters,
- debug report for raw generation snapshots and internal tokens.
