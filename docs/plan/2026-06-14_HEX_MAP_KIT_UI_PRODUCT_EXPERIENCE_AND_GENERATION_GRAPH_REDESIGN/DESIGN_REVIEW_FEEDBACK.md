# Design Review Feedback

Date: 2026-06-19
Policy: `docs/policy/DESIGN_REVIEW_POLICY.md`
Scope: task packets under `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/`
Test note: tests were not rerun for this review because the request states the test code has already passed.

## Coverage

20 task packets were reviewed. `PARK-50_QA_VALIDATE_HOLD` is a queue-only parked row and has no task packet directory, so no per-packet design review file was created for it.

| task packet | review file | decision | implementation feedback |
|---|---|---|---|
| `ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE` | `docs/review/plan/ADOPT-00_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `DESIGN-10_BACKBONE_WIREFRAMES` | `docs/review/plan/DESIGN-10_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `DESIGN-11_TAB_IA_AND_PRIORITY` | `docs/review/plan/DESIGN-11_DESIGN_REVIEW_2026-06-19.md` | `pass_with_followups` | `DRF-001`, `DRF-002` |
| `GRAPH-10_MODEL_AND_HEADLESS_PASSES` | `docs/review/plan/GRAPH-10_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `GRAPH-11_BUILD_TAB_GRAPH_CANVAS` | `docs/review/plan/GRAPH-11_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN` | `docs/review/plan/GRAPH-12_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP` | `docs/review/plan/GRAPH-12A_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `GRAPH-13_RUN_UX` | `docs/review/plan/GRAPH-13_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `GRAPH-14_GRAPH_RESOURCE` | `docs/review/plan/GRAPH-14_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API` | `docs/review/plan/RUNTIME-50_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP` | `docs/review/plan/RUNTIME-51_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `SCREEN-30_BUILD_TAB_FULL` | `docs/review/plan/SCREEN-30_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `SCREEN-31_PAINT_AS_DESIGN_WORKSPACE` | `docs/review/plan/SCREEN-31_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `SCREEN-32_EXPORT_AS_HANDOFF` | `docs/review/plan/SCREEN-32_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `SCREEN-40_CATALOG_VISUAL_BOARD` | `docs/review/plan/SCREEN-40_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `SCREEN-41_LAYERS_STACK_VISUAL` | `docs/review/plan/SCREEN-41_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS` | `docs/review/plan/RESCTX-42_DESIGN_REVIEW_2026-06-19.md` | `pass_with_followups` | `DRF-001` |
| `PROCESS-60_METRIC_AS_REGRESSION_ONLY` | `docs/review/plan/PROCESS-60_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `DOC-70_WORKFLOW_MANUAL` | `docs/review/plan/DOC-70_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |
| `PROC-90_FINAL_DIST_REGEN` | `docs/review/plan/PROC-90_DESIGN_REVIEW_2026-06-19.md` | `pass` | none |

## Summary

Graph model/runtime/build/paint/export/catalog/layers/resources/manual/dist task packets have enough current-state code or artifact evidence for their stated task scope.

The implementation shortage is concentrated in the workspace shell / IA layer that DESIGN-11 specified:

- The global top strip / workspace home is designed, but not implemented.
- QA / Validate are designed as parked diagnostics surfaces outside the tab bar, but current code still exposes them as normal tabs.

This means the queue's feature work is mostly implemented, but the main-route IA proof is weaker than the queue status implies. The gap does not invalidate the graph/runtime implementation, but it does mean the workspace first impression still diverges from the accepted DESIGN-11 shell.

## DRF-001 Global Top Strip / Workspace Home Is Missing

Classification: implementation shortage
Related packets: `DESIGN-11_TAB_IA_AND_PRIORITY`, `RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS`
Severity: product UX / IA gap

### Expected

`DESIGN-11_TAB_IA_AND_PRIORITY/TAB_IA.md` specifies a global top strip above the tab bar. It should always show:

- active map,
- save/setup state,
- `Build > Paint > Export`,
- current step,
- missing setup CTA,
- `[Diagnostics]`.

`RESCTX-42` then removes per-tab Map duplication on the assumption that global Map ownership exists in that top strip.

### Current Evidence

- `DESIGN-11_TAB_IA_AND_PRIORITY/IMPLEMENTATION_PLAN.md` explicitly says the task creates `TAB_IA.md` and makes no code changes.
- `RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS/SUB_TASKS.md` says global top strip is outside RESCTX-42 scope.
- Code search finds `Build > Paint > Export` and top-strip language only in docs, not in workspace UI code.
- `addons/hex_map_kit/editor/hex_map_workspace.gd` sets `global_map_chip_duplicated=false` in screen snapshots, but no live global top strip owns the Map context.
- Tests check that per-tab Map chips are not duplicated, but do not prove a replacement global Map/workflow strip exists.

### Why It Was Not Implemented

The accepted design was documented in DESIGN-11, but DESIGN-11 was scoped as a design-only packet. Later implementation packets treated the global strip as already-owned by DESIGN-11 or out of scope:

- DESIGN-11: documents IA/top strip only.
- RESCTX-42: removes local duplication and explicitly excludes global top strip.
- No follow-up task packet was added to implement the workspace shell component.

### Needed To Proceed

Create a new implementation task packet for the workspace shell, for example `SHELL-10_GLOBAL_TOP_STRIP_AND_DIAGNOSTICS`.

Minimum acceptance:

- Add a real workspace top strip component above `TabContainer`.
- Show active map, save/missing setup state, current `Build > Paint > Export` step, next CTA, and Diagnostics action.
- Make the strip state-driven from selected `HexTileMapLayer`, `HexMapWorkspaceAssetContext`, dirty/missing resource state, and current tab.
- Add headless UI tests proving both configured and missing setup states.
- Update RESCTX/Build/Paint/Catalog/Layers/Export snapshots so `global_map_chip_duplicated=false` is backed by an actual global owner.

## DRF-002 QA / Validate Are Still Direct Workspace Tabs

Classification: implementation shortage
Related packets: `DESIGN-11_TAB_IA_AND_PRIORITY`, queue row `PARK-50_QA_VALIDATE_HOLD`
Severity: product UX / IA gap

### Expected

DESIGN-11 specifies that the visible tab bar should contain:

```text
Build, Paint, Catalog, Layers, Resources, Export, Settings
```

QA and Validate should be parked and reachable only from `[Diagnostics]`. They should observe product state but not define the main creation path.

### Current Evidence

- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd` still defines `TAB_VALIDATE` and `TAB_QA` as regular tab names.
- `HexMapWorkspaceComponentRegistry.tab_names()` returns `Build, Paint, Catalog, Layers, Resources, Validate, QA, Export, Settings`.
- `tests/test_editor_workspace.gd` expects `Validate` and `QA` in `expected_tabs`.
- There is no current workspace diagnostics drawer implementation that owns QA/Validate access.

### Why It Was Not Implemented

The queue includes `PARK-50_QA_VALIDATE_HOLD`, but it is a `PARKED` row with target files `(現状維持)`, not an implementation packet. The row prevents QA/Validate from blocking the main route, but it does not physically move them out of the tab bar.

Earlier QA/Validate tests and snapshot contracts still depend on those surfaces being normal tabs, so no implementation packet changed the registry or routing.

### Needed To Proceed

Fold this into the same `SHELL-10_GLOBAL_TOP_STRIP_AND_DIAGNOSTICS` task or create a paired `SHELL-11_PARK_QA_VALIDATE_DIAGNOSTICS_DRAWER` task.

Minimum acceptance:

- Remove `Validate` and `QA` from `HexMapWorkspaceComponentRegistry.tab_names()`.
- Preserve their screen contracts as diagnostics surfaces rather than deleting their components.
- Add a Diagnostics drawer/open state from the global top strip.
- Route existing validation issue focus, QA seed lab, and debug/report state through Diagnostics.
- Update tests that currently assert Validate/QA as normal tabs.
- Ensure main-route UI metric / screen contract scenarios do not treat QA/Validate as first-class tab-bar surfaces.

## Tracking Gap

`PARK-50_QA_VALIDATE_HOLD` has no task packet directory. That is acceptable if park means "do not implement now", but it also explains why the physical park was never enforced. If QA/Validate park is part of the accepted product shell, it needs a real task packet rather than a queue-only parked row.

## Not Shortage

The following items were reviewed and did not produce implementation shortages within their task scope:

- graph model/headless passes,
- Build graph canvas and vertical graph chain,
- graph resource and runtime build API,
- graph load/context ownership,
- Build Simple + Graph unification,
- Paint workspace,
- Export handoff cards,
- Catalog visual board,
- Layers role stack visual,
- Resources shelf/context chips except for the missing global owner noted in `DRF-001`,
- metric-as-regression policy,
- workflow manual,
- final dist regeneration.


設計レビュー上の結論:
Graph / Runtime / Build / Paint / Export / Catalog / Layers / Resources / Manual / Dist の各 task は、現在の task scope に対して実装証跡あり。
実装不足は主に DESIGN-11_TAB_IA_AND_PRIORITY の workspace shell / IA 層に集中しています。
残項目:
DRF-001: Global top strip / workspace home が未実装  
DESIGN-11 で設計された Map / 状態 / Build > Paint > Export / Missing CTA / Diagnostics の常設 top strip が、コード上まだ存在しません。
RESCTX-42 は per-tab の Map chip 重複を消しているため、Map context の実オーナーが未実装のまま残っています。

DRF-002: QA / Validate がまだ通常タブとして残っている  
設計では QA / Validate は [Diagnostics] drawer 配下の parked surface。
現コードでは HexMapWorkspaceComponentRegistry.tab_names() に Validate / QA が残っており、通常タブとして表示される前提の tests も残っています。

なぜ未実装だったか:
DESIGN-11 は設計文書化だけが scope で、コード変更なし。
PARK-50_QA_VALIDATE_HOLD は queue-only の parked row で、task packet がなく、物理的に QA/Validate を drawer 化する実装 task ではありません。
後続 task は Build/Paint/Resources など個別 screen を実装しましたが、workspace shell 自体を実装する task が作られていません。
次に必要なこと:
SHELL-10_GLOBAL_TOP_STRIP_AND_DIAGNOSTICS のような新規 task packet を作る。
top strip を TabContainer の上に実装する。
Diagnostics drawer を追加し、QA / Validate を通常タブから移す。
既存 tests の Validate / QA 通常タブ前提を更新する。
