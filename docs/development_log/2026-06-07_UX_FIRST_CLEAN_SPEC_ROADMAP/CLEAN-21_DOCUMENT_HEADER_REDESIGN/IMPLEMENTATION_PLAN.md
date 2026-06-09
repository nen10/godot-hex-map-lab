# CLEAN-21 Implementation Plan

1. Mark CLEAN-21 `RUNNING` in the queue.
2. Add document header buttons: New Document, Open..., Save, Save As..., Validate.
3. Track and render document state as selected/saved/dirty/validation summary.
4. Update Save behavior so Save uses saved path or falls through to Save As, while Save As always opens FileDialog.
5. Relabel import/export as advanced conversion/export actions.
6. Update editor tests and docs.
7. Run `./tools/test.sh`, self-review, repair `repair-now` issues, update queue, and commit.
