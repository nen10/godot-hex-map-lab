# UI-METRIC-02 UX

## User Goal

Codex should be able to run one quick static command and see likely Workspace UI contract risks before waiting for Godot layout snapshot tooling.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Report-only static audit | high | low | medium | adopt | It gives immediate signal without blocking existing work on heuristic findings. |
| B. Fail standard tests on static findings now | medium | high | medium | reject | The initial detector will have false positives until metric gates are tuned. |
| C. JSON-only output | medium | medium | low | reject | Humans need readable command output now; JSON can be optional later. |
| D. Text output with category/file/line | high | low | low | adopt | It is useful for self-review and repair tasks. |

## Adopted UX

- `python3 tools/ui_static_audit.py` prints a categorized report.
- Findings include file, line, category, severity, and message.
- The command exits 0 by default so it can be used before P0 gate integration.
- `--strict` can return nonzero when a caller intentionally wants failure behavior.

## Deferred UX

- Standard test integration moves to `UI-METRIC-07`.
- Runtime visibility and layout checks move to `UI-METRIC-03` onward.

## Experience Steps

1. Run the static audit command.
2. Inspect findings grouped by category.
3. Use findings as repair input or self-review evidence.
4. Later gate tasks decide which findings become failures.

## Existing UX Interference

The audit must not bless current visible debug/path/sample behavior. It reports suspicious patterns without requiring immediate code changes in this slice.
