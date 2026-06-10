# PROCESS-10 UX

## User Goal

Codex should be able to look at a queue task, classify its complexity, and know how much planning proof is required before implementation starts.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep one planning template for all tasks | low | high | low | reject | Small tasks and phase-scale tasks need different proof depth. |
| B. Add C1-C5 classes in `PLANNING_POLICY.md` | high | low | low | adopt | It is visible at the point all task plans already reference. |
| C. Use only labels like small/medium/large | medium | medium | low | reject | The feedback asks for C1-C5 and artifact requirements. |
| D. Force C4/C5 to split before any implementation | medium | medium | medium | adopt with condition | C5 must split when one completion boundary is not defensible; C4 can proceed if required matrices make the proof concrete. |

## Adopted UX

- Every future `SUB_TASKS.md` starts with a complexity header.
- Larger tasks have explicit required artifacts instead of relying on ad hoc judgment.
- C4/C5 tasks must expose fallback/mirror and state/invariant risk before implementation.

## Deferred UX

- Dedicated template files remain out of scope for this slice.
- Completed historical plan docs are not rewritten.

## Experience Steps

1. Read queue task acceptance.
2. Choose C1-C5 in `SUB_TASKS.md`.
3. Fill the required matrices for that class.
4. Use Review before implementation to check the artifacts before editing code/docs.

## Existing UX Interference

The existing policy already requires candidate matrices and fallback handling in several places. This task makes those requirements conditional and explicit rather than replacing them.
