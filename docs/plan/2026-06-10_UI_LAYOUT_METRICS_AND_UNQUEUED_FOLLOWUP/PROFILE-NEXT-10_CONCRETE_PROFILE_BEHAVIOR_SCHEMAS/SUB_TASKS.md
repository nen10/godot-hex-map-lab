# PROFILE-NEXT-10 Sub Tasks

Task: `PROFILE-NEXT-10_CONCRETE_PROFILE_BEHAVIOR_SCHEMAS`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Complexity

Class: C3
Reason:
- The task touches three profile Resource classes and their Validate / QA / Export screen snapshots.
- Completion requires Resource/API serialization tests plus editor state proof, not a single document update.
- The behavior schema must avoid metadata-only or sample-only completion.

Required artifacts:
- Task resolution and scheduled task audit.
- UX candidate matrix.
- Fallback / mirror handling table.
- State / invariant table.
- Dependency / test matrix.

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Typed behavior schema methods on each profile Resource | adopt | The behavior contract belongs to the concrete Resource instead of editor-only dictionaries. |
| Screen snapshot exposure for selected profiles | adopt | Validate / QA / Export must show the active behavior schema connection. |
| Use `metadata`, `parameters`, or `options` as the only behavior contract | reject | These are open dictionaries and do not satisfy concrete schema acceptance. |
| New visual editor for profile field editing | reject | The queue asks for schemas and screen connections; a full editor would be new scope. |
| Sample preset-only behavior proof | reject | Completion must work with project-created Resources. |

## Sub Tasks

| id | work | completion signal |
|---|---|---|
| `PROFILE-NEXT-10.01` | Add typed schema fields and schema helper methods to Validation Suite, Generation Profile, and Export Profile Resources. | Each Resource returns a durable `behavior_schema()` dictionary and focused helper values. |
| `PROFILE-NEXT-10.02` | Connect profile schema snapshots to Validate / QA / Export contexts. | Screen snapshots include schema kind, status, and summary without using raw metadata as primary UI. |
| `PROFILE-NEXT-10.03` | Add resource/editor tests and docs. | Adapter save/load and editor screen assertions cover all three profile schemas. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full profile visual editor | none | reject for this task | Schema and screen context are the current acceptance boundary. |
| Root reducer ownership of profile events | `STATE-NEXT-10` | defer to existing queue | Event/reducer separation is already queued. |
| Export package build UI | `EXPORT-NEXT-10` | defer to existing queue | Package build belongs to Export product decision work. |
| Sample preset-only profile flow | none | reject | Project-created Resources must be sufficient. |

## Non Goals

- Do not build a full profile field editor.
- Do not change generation algorithms, validation rules, or export file formats.
- Do not advance any READY queue after `PROFILE-NEXT-10` in this run.
