# CLEAN-24 Implementation Plan

1. Mark CLEAN-24 `RUNNING` in the queue.
2. Add layer stack template selection state and role rows.
3. Add Create Missing Layers, Apply Document, and Clear Role actions.
4. Connect role rows to target `HexTileMapLayer` status.
5. Update editor tests and docs.
6. Run `./tools/test.sh`, self-review, queue update, and commit.
