# UIR-01 Implementation Plan

## Scope

- Create `docs/review/roadmap/WORKSPACE_VISIBLE_UI_INVENTORY_2026-06-08.md`.
- Record source/readback evidence for current tabs, components, asset slots, scroll ownership, visible action buttons, and missing design.
- Update queue proof and promote dependencies.

## Change Targets

- `docs/review/roadmap/WORKSPACE_VISIBLE_UI_INVENTORY_2026-06-08.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/review/autopilot/UIR-01_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/UIR-01_TEST_RESULT_2026-06-08.md`

## Steps

1. Inspect `HexMapWorkspaceComponentRegistry`.
2. Inspect `HexMapWorkspace` tab/page mounting.
3. Inspect `HexMapWorkspaceAssetPanel`, `HexMapEditorAssetSlotControl`, and `HexMapSampleSettingsPanel`.
4. Write tab-by-tab inventory.
5. Run `./tools/test.sh`.
6. Self-review for sample-only completion and repair-now items.
7. Sweep queue dependencies.

## Deferred Steps

- Do not rename Document to Resources here.
- Do not add ScrollContainers here.
- Do not remove buttons here.
- Do not create analog tests.

## Test Path

```sh
./tools/test.sh
```

## Completion Checklist

- Inventory includes Document, Paint, Catalog, Layers, Validate, QA, Export, and Settings.
- Display bugs are separated from missing design.
- Source/readback evidence is named.
- Next tasks are clear.
