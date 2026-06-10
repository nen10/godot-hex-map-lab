# Visible Control Inventory

## Decision Labels

| label | meaning |
|---|---|
| Keep | Control is a real user action or necessary state display. |
| Simplify | Control remains, but visible text/layout should be reduced. |
| Hide detail | Information moves to tooltip/detail/debug report. |
| Move | Control belongs to another tab or later task-owned surface. |
| Remove | Control is a no-op or placeholder and should not remain visible. |

## Inventory

| surface | visible control/state | decision | owner task | notes |
|---|---|---|---|---|
| Workspace root | selected HexTileMap context | Keep/Simplify | `SCREEN-10` | Keep selected map and auto-link summary visible; node path and writeback internals are debug/detail. |
| Sample CTA | learn/dismiss sample learning | Keep | current | CTA changes state and routes Settings; sample remains learning/onboarding only. |
| Resource rows | title + picker | Keep/Simplify | `UI-01` | Role label and picker remain visible; path is tooltip/debug. |
| Resource rows | status text `OK/Missing/Optional/Warn/Invalid` | Simplify | `UI-01` | Move toward icon+tooltip; short text is temporary state shorthand. |
| Resource rows | type/current/messages detail labels | Hide detail | `UI-01` | Keep in tooltip or real detail surface, not always-open text. |
| Resource rows | Create New | Keep | current/UI-01 | Real action; disabled/unavailable state must explain itself. |
| Resource rows | Learn With Sample | Keep/Simplify | current/UI-01 | Visible only when sample source is explicit; never silent fallback. |
| Resource rows | Details placeholder | Remove | `UI-01` | Do not add visible Details unless it opens a real detail drawer. |
| Resources | Create Missing Resources | Keep | `SCREEN-10` | Real state-changing action for selected node unique resources. |
| Generate | generation parameter controls | Keep | `UI-03` | Do not hide working controls during empty-area repair. |
| Generate | progress/cancel/apply status | Keep/Simplify | `UI-03` | Must come from `HexMapGenerationRunState` ViewState. |
| Generate | reload-like action | Remove unless specified | `UI-03` | Only allowed if it has a clear state purpose. |
| Paint | brush mode/key controls | Keep | `SCREEN-22` | Paint is task surface; raw payload controls stay hidden/debug. |
| Paint | resource setup rows | Move/Hide | `SCREEN-20`, `SCREEN-21` | Catalog/Layer/Document/Export setup belongs to owner tabs. |
| Catalog | catalog asset row | Keep/Simplify | `SCREEN-20` | Catalog owns editing controls and preview. |
| Catalog | source id/atlas coordinate text | Hide detail | `SCREEN-20` | Diagnostic detail, not primary Paint UI. |
| Layers | layer role rows | Keep/Simplify | `SCREEN-21` | Roles/visibility/target relationship remain visible. |
| Validate | Run Validation | Keep | `SCREEN-23` | Real workflow command. |
| Validate | issue rows/focus action | Keep/Simplify | `SCREEN-23` | Rule ids/detail move to row tooltip/detail when too dense. |
| QA | seed lab run/select/promote controls | Keep | `SCREEN-24` | QA task owns seed comparison and promotion. |
| Export | choose destination/use recent/export | Keep/Simplify | `SCREEN-25` | Destination path is tooltip/detail; output type and readiness visible. |
| Settings | boolean true/false text labels | Simplify | `UI-02` | Use checkbox/toggle state, not redundant text. |
| Settings | debug numeric fallback state | Hide detail | `UI-02` | Explicit opt-in remains, debug payload goes to debug report/copy flow. |

## Repair-Now Check

No new repair-now item is identified by this inventory. The remaining simplification/move/remove work is already represented by `UI-01`, `UI-02`, `UI-03`, and later screen tasks.
