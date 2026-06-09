# CLEAN-22 Implementation Plan

1. Mark CLEAN-22 `RUNNING` in the queue.
2. Add catalog resource, TileSet, and PackedScene picker state to `HexMapEditTool`.
3. Add catalog entry rows with key, type, preview, tags, and validation status.
4. Add Add Atlas Entry, Add Scene Entry, and Validate Catalog actions.
5. Keep normal floor/wall/overlay/object paint controls catalog-key based, hiding numeric atlas controls from normal mode.
6. Update editor tests and docs.
7. Run `./tools/test.sh`, self-review, repair `repair-now` issues, update queue, and commit.
