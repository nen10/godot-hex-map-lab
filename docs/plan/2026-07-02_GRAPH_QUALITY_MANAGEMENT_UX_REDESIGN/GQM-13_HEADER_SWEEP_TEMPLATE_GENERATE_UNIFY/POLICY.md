# GQM-13 Policy

## Adoption

- Graph templates are `graphs` assets listed through `HexMapAssetLibrary.list("graphs")`.
- Bundled templates are read-only starting points; project saves go to the project graph layer.
- Generate has one UI meaning: run the current canvas graph and project the result.
- A replacement confirmation is required when applying/loading a template over an existing canvas graph.

## Non-Adoption

- No Profile/Simple screen route remains.
- No batch/randomize controls remain in the Build header.
- No inspector, criteria chip, canvas titlebar, result-row, or pointer changes.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Simple/Profile UI fallback | remove | Simple is a graph template, not a separate route. | done in this task | header snapshot and no Profile/Simple assertions |
| Headless `HexGenerationPreset.from_profile` | keep | API/preset compatibility is explicitly retained. | none | preset factory test remains headless |
| Workspace load-generation API overwrite parameter | keep | Existing headless load behavior is outside the header UI route. | future API cleanup only if queued | existing graph load tests |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Header | Only graph asset operations and Generate/Apply/Revert/status are visible. | old controls remain hidden in another row | header snapshot |
| Template selection | Bundled/project list comes from `HexMapAssetLibrary.list("graphs")`; `基本形` is first. | sample-only template completion | bundled basic + project round-trip tests |
| Generate | Runs current canvas graph without profile fallback. | graphless context fails | workspace bootstrap test without profile |
| Save as / Load | Save writes project `graphs`; Load uses normalized graph resource load. | bundled overwrite or stale resource load | Save as -> Load round-trip |
