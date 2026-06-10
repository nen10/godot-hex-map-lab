# UI-METRIC-02 Static UI Audit Sub Tasks

## Complexity

Class: C4
Reason:
- This task adds a new static audit tool that scans editor UI source for several UX contract risks.
- It touches tooling and test documentation, but it remains report-only until later gate tasks.
- False positives must be bounded with categories and stable output instead of failing standard tests now.

Required artifacts:
- Task Resolution candidate matrix
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling table
- State / Invariant Table
- Dependency / Test Matrix
- Standard test proof

## Task Resolution Candidate Matrix

| candidate | decision | reason |
|---|---|---|
| Add `tools/ui_static_audit.py`. | Adopt | This is the required deliverable. |
| Detect suspicious `Button.new()` without `pressed.connect`. | Adopt | Visible no-op buttons are a P0 metric target. |
| Detect forbidden placeholder button text. | Adopt | Details/Open/Select/Validate-style placeholders were called out by policy. |
| Detect visible debug/raw/path label patterns. | Adopt | Debug leakage is a P0 metric target. |
| Detect generic `EditorResourcePicker` base type patterns. | Adopt | Required Resource pickers need concrete type filters. |
| Detect tab constructors without ScrollContainer suspicion. | Adopt | Missing scroll reachability is a P0 metric target. |
| Add the tool to `tools/test.sh` as a failure gate now. | Reject | Integration/gating belongs to `UI-METRIC-07` and P0 gate tasks. |
| Build a full GDScript parser. | Reject | Heuristics are sufficient for initial static audit; runtime snapshot will complement it. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| P0 failure gate | `UI-METRIC-05`, `UI-METRIC-07` | already queued | This task is report-only. |
| Runtime layout confirmation | `UI-METRIC-03` | already queued | Static audit cannot prove layout or visibility. |
| Full parser / AST audit | none | rejected | Too much implementation cost for the first static audit. |

## Scheduled Task

No scheduled task is added from this slice.
