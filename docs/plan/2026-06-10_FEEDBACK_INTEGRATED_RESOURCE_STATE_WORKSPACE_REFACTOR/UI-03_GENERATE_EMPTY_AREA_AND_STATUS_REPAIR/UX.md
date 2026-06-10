# UI-03 UX

## User Goal

Generate should immediately explain whether a candidate exists, whether it is only a preview, whether it can be applied to the selected Level Document, and what Reload will refresh.

## Operation Steps

1. Open Generate.
2. Review the run/output result summary before changing parameters.
3. Generate a candidate preview.
4. Confirm visible preview and document/apply state.
5. Apply the candidate to the selected Level Document when desired.
6. Use Save As `.tres` for file output and see that save state is part of the result summary.
7. Reload mapdata sources only when the underlying source file changed.

## Adopted UX

- Empty-state text appears only for a real generation block reason.
- Result state is visible as a concise summary separate from raw debug state.
- Preview-only and selected-document output modes are distinguishable.
- Apply/save state is represented in snapshots and visible status text.
- Mapdata source Reload communicates file refresh purpose through label/tooltip.

## Deferred UX

- Full Generate tab layout redesign is deferred.
- Rich preview thumbnails are deferred to later Generate/QA work.
