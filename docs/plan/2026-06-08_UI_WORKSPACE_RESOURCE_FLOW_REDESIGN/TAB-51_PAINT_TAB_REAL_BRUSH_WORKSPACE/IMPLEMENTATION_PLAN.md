# TAB-51 Implementation Plan

Task: `TAB-51_PAINT_TAB_REAL_BRUSH_WORKSPACE`

## Steps

1. Update the workspace registry/mounting so Paint owns the brush/edit component only, while Resources remains the Object/Label asset owner.
2. Keep object/label create/open/save helpers functional by routing them through the Resources asset panel.
3. Add a Paint workspace summary snapshot with active document, layer, brush, selected/last cell, last edit, and undo hint.
4. Route consumed viewport edit input to the Paint tab.
5. Update brush CTAs for missing object/label resources to point to Resources.
6. Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`, self-review, repair any `repair-now`, update queue proof, and commit.
