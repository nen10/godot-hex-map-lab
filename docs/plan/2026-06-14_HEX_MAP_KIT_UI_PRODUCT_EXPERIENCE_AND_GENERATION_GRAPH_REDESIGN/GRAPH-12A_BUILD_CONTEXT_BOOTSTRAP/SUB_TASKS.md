## Complexity

Class: C3
Reason:
- Build tab UI state, selected HexTileMapLayer binding, and generation graph ownership interact.
- The task repairs a blocking Resource-context gap before GRAPH-13 run UX can be meaningful.
- It needs code, tests, queue proof, and UI/graph experiential completion evidence.

Required artifacts:
- SUB_TASKS.md
- UX.md
- POLICY.md
- IMPLEMENTATION_PLAN.md

## Task Resolution

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Keep Build blocked until Resources creates document | reject | This preserves the current Resource-reference shortage and makes Build unable to realize the graph path from an unconfigured map. |
| B. Auto-inject bundled samples | reject | Sample-only completion is not production feature completion. |
| C. Build context bootstrap creates/embeds missing selected-node resources | adopt | Matches `GENERATION_GRAPH_MODEL.md` §10 default embed semantics and keeps existing selected-node tracking as the owner. |
| D. Implement full graph save/load resource lifecycle now | reject | Full save/load remains `GRAPH-14`; this task only creates the missing UI execution path and an embedded graph handle. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full graph resource save/load round-trip | `GRAPH-14_GRAPH_RESOURCE` | existing queue | This task only needs an embedded graph handle for Build UI execution. |
| Runtime graph resource build API | `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API` | existing queue | Runtime API depends on GRAPH-14. |
| Opt-in overwrite of existing HexTileMapLayer graph load | `RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP` | existing queue | This repair implements the default/new/graph-less path; overwrite remains scoped to RUNTIME-51. |

## Scheduled Task

none
