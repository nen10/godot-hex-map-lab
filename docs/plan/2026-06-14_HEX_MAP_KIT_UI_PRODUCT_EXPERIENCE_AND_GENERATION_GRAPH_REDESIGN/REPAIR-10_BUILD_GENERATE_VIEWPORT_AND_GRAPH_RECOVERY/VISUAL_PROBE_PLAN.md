# REPAIR-10 Visual Probe Plan

## Purpose

Before relying on tests, run a diagnostic path that records whether Build Generate actually projected to a viewport layer. This is diagnostic proof, not an analog test.

## Probe Contract

The probe writes:

- selected layer name/path,
- whether the layer is inside the tree,
- whether Build context created document/graph/layer,
- Generate run result,
- viewport projection report,
- display used cell count,
- display tile status,
- screenshot capture status if available,
- non-background pixel sample count if screenshot capture is available.

Output directory:

`./.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/`

## Failure Interpretation

- If graph cache exists but projection report fails, the repair is incomplete.
- If `display_used_cell_count() == 0`, the repair is incomplete.
- If layer path is empty or not inside the tree, the repair is incomplete.
- If only thumbnail/cache data is present, the repair is incomplete.

## Expected Proof Files

- `build_generate_viewport_probe.json`
- `build_generate_viewport_probe.png` when screenshot capture is available in the runtime
