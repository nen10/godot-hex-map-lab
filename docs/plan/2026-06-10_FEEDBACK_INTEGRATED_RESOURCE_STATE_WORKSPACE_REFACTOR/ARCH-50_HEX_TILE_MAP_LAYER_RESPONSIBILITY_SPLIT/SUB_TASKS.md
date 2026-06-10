# ARCH-50 HexTileMapLayer Responsibility Split Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Extract resource binding preparation into a helper. | Adopt | `hex_map` resource assignment and normalized runtime snapshot creation are not UI node coordination. |
| Extract document apply preparation into a helper. | Adopt | Document duplication and conversion to runtime map should be separate from display application. |
| Keep `HexTileMapLayer` as coordinator for node/layer/tile redraw. | Adopt | Rendering and scene-tree mutation remain local to the node for this slice. |
| Extract gameplay query, object layer, and debug overlay adapters now. | Defer | Those are larger changes and are not required to prove document apply/resource binding separation. |
| Rewrite all runtime helper APIs. | Reject | Existing runtime helper value must be preserved. |

## Scheduled Task

No follow-up task is scheduled from this slice. Further object/query/debug extraction can be handled in a later roadmap if needed.
