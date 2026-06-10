# Policy

## Adopted Decisions

- Generate layout structure is part of the screen contract and must be exposed through a snapshot, not only through visual labels.
- `HexMapGenDock` remains the orchestration owner; component builders own physical control construction for the groups already extracted by `ARCH-NEXT-11`.
- Apply, Save, Preview, and Performance purpose must be explicit in section metadata and visible state labels.
- Existing generation behavior, output target semantics, and chunked apply reports must be preserved.

## Rejected Decisions

- Do not rewrite generation execution or private state mirrors in this task.
- Do not use bundled samples as silent Generate readiness.
- Do not introduce generic "reload" UI without a specific source/profile purpose.
- Do not make thumbnail rendering a hidden dependency of this layout task.

## Resource / API / UI Boundary

- Resource/API behavior remains unchanged.
- UI grouping is owned by Generate layout section metadata and mounted Controls.
- Workspace screen snapshots may consume Generate layout snapshot data for acceptance proof.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Existing `_generation_*` private mirrors | keep for this task | State retirement is scheduled separately. | `STATE-NEXT-11` removes or makes them read-only. | Existing generation state tests plus layout snapshot tests. |
| Output target ViewState | keep as source of truth for preview/document/save state | Already covers preview-only and selected-document distinctions. | Replaced by GenerationResultResource workflow. | NODE-24 output target assertions. |
| Sample catalog controls | do not use as production fallback | Sample-only completion is forbidden. | Sample detail drawer/learning flow owns sample inspection. | UI metric sample separation gate. |
| Preview thumbnail placeholder | defer, no fake placeholder | Fake thumbnails would imply unimplemented visual proof. | `GEN-NEXT-11` implements project data thumbnails. | Layout tests reserve Preview section without thumbnail claims. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Input section | Generation shape/size/seed/run controls are grouped as configuration. | User mistakes output actions for input setup. | Layout snapshot section contains run controls and input role. |
| Profile / Source section | Source registry and generation profile controls are separate from output apply. | Browse/reload purpose appears generic or disconnected. | Layout snapshot action purpose records `source_load`. |
| Preview section | Preview/result state is visibly distinct from document mutation. | Preview-only state appears applied or saved. | Existing output ViewState tests plus Preview section snapshot. |
| Apply / Save section | Apply to Document and Save As `.tres` are explicit output actions. | User cannot tell Save and Apply are different destinations. | Layout snapshot action purposes and NODE-24 apply/save states. |
| Performance section | Busy/progress/cancel state is separate from result readiness. | Heavy apply/generation appears idle. | Progress snapshot and layout section proof. |

## Completion Rule

`GEN-NEXT-10` is complete only when tests prove all required section ids exist, action purposes are classified, and `./tools/test.sh` reports UI metric P0 failures = 0.
