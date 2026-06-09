# CLEAN-23 Implementation Plan

1. Mark CLEAN-23 `RUNNING` in the queue.
2. Add object definition list state and rows to `HexMapEditTool`.
3. Add selected-definition `PackedScene` picker and Add Definition action.
4. Populate object placement key selector from object database definitions.
5. Add typed property controls for bool, int, float, string, enum schema, and Resource where editor APIs exist.
6. Hide raw object id and raw JSON property text from normal object mode.
7. Update tests and docs, run `./tools/test.sh`, self-review, queue update, and commit.
