# GQM-13 Sub Tasks

## Complexity

Class: C3
Reason:
- Build header UX, graph template resources, workspace handoff, and tests change together.
- The task removes old Profile/Simple/Batch UI contracts and replaces them with graph asset operations.
- Completion depends on both structure tests and graph execution proof.

Required artifacts:
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`
- self-review and proof log after execution

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Header sweep only | reject | Would leave Simple/Profile and graph asset operation behavior split. |
| Template + Save as/Load asset operation | adopt | Matches `RESOURCE_MODEL.md` §4/§6 and the GQM-13 contract. |
| Rework inspector/criteria chip asset UX | reject | Assigned to GQM-18 and explicitly out of scope. |
| Add a new analog test | reject | CLEAN UI work forbids new analog tests unless requested. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| inspector / criteria chip polish | `GQM-18_CRITERIA_CHIP_POLISH` | existing queue | User explicitly forbids touching this scope. |
| generated result save/switch | `GQM-14_RESULT_RESOURCE_SAVE_SWITCH` | existing queue | Separate Phase G3 task. |

Scheduled task: none.
