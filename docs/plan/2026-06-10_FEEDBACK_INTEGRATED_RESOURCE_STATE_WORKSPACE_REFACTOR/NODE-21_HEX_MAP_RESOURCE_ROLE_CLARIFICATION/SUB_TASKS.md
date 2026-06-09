# NODE-21 Hex Map Resource Role Clarification Sub Tasks

## Goal

Clarify `HexTileMapLayer.hex_map` as runtime/display snapshot data, while Level Document remains the canonical authoring resource.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Remove `hex_map` | Reject | Runtime and existing display helpers still use `HexMapResource`; removal belongs to a later layer responsibility split. |
| B. Keep `hex_map` as runtime/display snapshot | Adopt | This matches current preview/apply behavior without making it authoring source of truth. |
| C. Keep target import from `hex_map` as temporary conversion | Adopt | Edit Tool can create an unsaved Level Document from target display data, but the editable document remains the authoring object. |
| Preserve "runtime initial map" wording | Reject | "Initial" reads like source-of-truth. UI/test contracts should say runtime display snapshot. |

## Scheduled Task

No scheduled task is required. Larger `HexTileMapLayer` responsibility split remains covered by `ARCH-50`.
