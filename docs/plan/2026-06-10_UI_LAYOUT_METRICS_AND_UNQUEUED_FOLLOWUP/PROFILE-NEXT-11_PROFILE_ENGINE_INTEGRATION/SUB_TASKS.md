# PROFILE-NEXT-11 Profile Engine Integration Sub-Tasks

## Complexity

Class: C3
Reason:
- This task connects three existing profile Resource schemas to three execution paths: validation, generation, and export.
- It changes behavior only when a concrete profile Resource is selected or passed in options.
- It needs adapter and editor tests, plus null-profile regression proof.

Required artifacts:
- Complexity header.
- Task resolution.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Dependency/test matrix.
- State/invariant table.

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Apply Validation Rule Suite inside `HexMapDocumentValidator` after issue collection. | Adopt | A single engine boundary covers workspace Validate and Generate validation paths. |
| Pass selected workspace Validation Rule Suite into document validation options. | Adopt | The selected project Resource must affect normal Validate/Generate workflows. |
| Overlay selected Generation Profile options onto generation snapshots. | Adopt | Existing generation code already consumes snapshots; profile integration can stay scoped and testable. |
| Reflect selected Export Profile options in export context and export action result. | Adopt | Export Profile must affect output type/file extension/inclusion flags without adding rejected export modes. |
| Add new visual profile editor controls. | Reject | PROFILE-NEXT-10 already exposed schemas; this task is engine behavior wiring, not a UI editor. |
| Add JSON/data/package export implementations. | Reject | EXPORT-NEXT-10 keeps non-runtime-handoff exports out of the active editor Export path. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full visual profile editor | none | explicit reject | Not needed for engine integration acceptance. |
| Data/package/debug export modes | none | explicit reject | EXPORT-NEXT-10 classified them as backlog/process/diagnostic outside normal Export UI. |

## Scheduled Task

No follow-up task is scheduled from this slice.
