# Workspace Screen Contract

## Global Rule

Each Workspace screen renders a ViewState. It may show short user-facing status and next actions, but it must not recombine private flags or expose raw debug/path/internal state as normal UI.

Information placement:

| placement | allowed content |
|---|---|
| Always visible | tab purpose, current readiness, selected user-facing role/resource name, status icon/short state, one or two next actions, primary workflow result |
| Tooltip/detail | resource path, type filter, source badge explanation, validation detail, blocked reason, longer help text |
| Debug report | root/screen state snapshots, node paths, raw ids, raw JSON, internal flags, filepath-heavy diagnostics |

Global prohibitions:

- No raw JSON in normal tabs.
- No filepath or node path as the primary visible label.
- No numeric fallback or debug fallback as normal feature text.
- No sample asset as silent default or production completion proof.
- No visible no-op buttons.

## Tab Contracts

| tab | user question | always visible | tooltip/detail | debug report only | primary commands | state source |
|---|---|---|---|---|---|---|
| Resources | What HexTileMap/document/resources am I editing? | selected HexTileMap summary, Level Document readiness, required/shared/optional resource groups, missing unique resource action | resource paths, source badge details, dependency hydration detail | node path, writeback relation internals, raw dependency snapshot | create/select Level Document, create missing unique node resources, select shared resources | `HexMapWorkspaceBindingService`, `HexMapWorkspaceRootState` |
| Generate | What candidate can I generate and where will it go? | generation mode/shape controls, run/progress/cancel state, preview/apply/document result summary | block reason, advanced generation parameter help, validation summary detail | generation snapshot metadata, raw run ids/tokens | generate, cancel, apply/promote through existing safe actions | `HexMapGenerationRunState` |
| Paint | What brush will edit which target/cell? | brush mode/key, target layer, document readiness, selected/hovered cell, last edit summary | missing asset route, target blocked reason, brush source detail | raw payload dictionaries, viewport trace, internal tile ids | choose brush, paint through viewport, route missing asset to owner tab | `HexMapPaintInteractionState` |
| Catalog | What catalog entries exist and can Paint/Generate use them? | Tile Catalog readiness, entry list/selected entry, preview availability, catalog validation summary | resource path, TileSet type/purpose, source id/atlas coordinates when needed for diagnosis | raw TileSet source ids, atlas internals | create/select Tile Catalog, assign TileSet, create/edit entries | Catalog screen snapshot synthesized ViewState |
| Layers | What layer roles are connected to the selected map? | Layer Stack readiness, role rows/status, target relationship, missing role action | node/resource paths, visibility/lock detail, relationship explanation | child node paths, raw writeback relationship map | select/create Layer Stack, create/apply role layers | Layer screen snapshot synthesized ViewState plus binding state |
| Validate | What issues block this workspace and where do I fix them? | run state, issue count/severity, issue rows, selected issue focus route | rule id, target component/slot, fix suggestion details | raw validation result object, full issue metadata | run validation, select issue/focus owner screen | `HexMapValidationWorkflowState` |
| QA | Which generated seed should become the document? | Generation Profile readiness, score rows, selected seed, promotion target | scoring inputs, validation suite detail, profile path | raw batch rows/generation snapshots | run seed lab, select seed, promote to Level Document | QA screen snapshot synthesized ViewState plus generation state |
| Export | What runtime handoff will be written? | output type, Level Document readiness, destination selected/missing, can-export state, last result | destination path, recent destination detail, Export Profile purpose | raw export action result, handoff diagnostics | choose destination, use recent destination, export runtime handoff | `HexMapExportWorkflowState` |
| Settings | What sample/debug preferences are enabled? | sample learning state, explicit toggles/checks, duplicate sample actions | sample asset paths, preference purpose text | debug numeric fallback payload, raw preference snapshot | toggle sample/debug settings, duplicate samples to project | `HexMapSampleLearningState` |

## Generate Caution

Generate must not be simplified by hiding working parameter, progress, preview, or apply controls. UI-03 may repair empty area and status wording, but it must preserve:

- generation mode/shape controls,
- generate/cancel/progress state,
- preview vs document/apply result distinction,
- block reasons from `HexMapGenerationRunState`,
- output target and validation result context.
