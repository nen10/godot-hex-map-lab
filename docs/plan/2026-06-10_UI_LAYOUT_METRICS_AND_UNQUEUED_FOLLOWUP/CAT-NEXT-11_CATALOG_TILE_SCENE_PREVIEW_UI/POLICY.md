# Policy

## Adopted Decisions

- Catalog preview rendering is owned by a Catalog-specific UI component.
- Preview availability must come from the selected project Tile Catalog entry and its Resource references.
- Missing TileSet, missing source, missing atlas tile, missing scene, placeholder, and invalid entry states are explicit unavailable preview states.
- The mounted UI must expose a badge/tooltip for unavailable state and a snapshot for headless proof.

## Rejected Decisions

- Do not silently substitute bundled sample catalog, sample atlas, or generated placeholder assets.
- Do not make Paint or Generate responsible for Catalog entry preview UI.
- Do not promote raw source id / atlas coordinates into primary editing controls for this task.
- Do not add analog tests.

## Resource / API / UI Boundary

- `HexMapCatalogEditorComponent` owns Catalog entry detail snapshots.
- `HexTileCatalogPreviewControl` owns Catalog preview drawing and snapshot storage.
- `HexMapCatalogScreen` owns the mounted detail panel structure.
- `HexMapWorkspace` binds current catalog state into the mounted detail panel and exposes screen snapshots.
- Tile catalog Resource schemas remain unchanged.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Sample catalog/atlas fallback | reject | Would hide unconfigured project state and violate sample policy. | none | Tests assert selected project catalog preview, not sample source. |
| Text-only preview as completion proof | reject | Rich preview acceptance requires a rendered control. | Preview control mounted. | Tests find mounted `HexTileCatalogPreviewControl`. |
| Unavailable badge | keep | It is the correct UX for invalid/missing source state. | Entry becomes renderable. | Tests assert badge and tooltip reason. |
| Raw metadata display | keep as non-primary snapshot metadata | Helpful for debug/test proof but not normal primary workflow. | none | Existing and new tests assert raw controls are non-primary. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| No catalog selected | Preview unavailable with no-catalog reason and badge tooltip. | Empty screen looks broken. | Catalog snapshot and mounted badge test. |
| Atlas entry with valid TileSet/source/tile | Preview available with atlas texture render kind. | Text-only success is mistaken for visual success. | Detail snapshot and mounted control test. |
| Scene entry with PackedScene | Preview available with scene render kind and scene metadata. | Scene entry appears unsupported. | Detail snapshot test. |
| Placeholder or invalid entry | Preview unavailable with reason. | Missing entry appears valid. | Placeholder/missing tests. |
| Raw catalog metadata | Metadata stays non-primary. | UX regresses toward raw source/coordinate editing. | Existing Catalog tests plus new preview assertions. |

## Completion Rule

`CAT-NEXT-11` is complete only when Catalog detail renders atlas and scene preview states through a mounted preview control, unavailable states expose a badge/tooltip reason, snapshots cover the states, and `./tools/test.sh` passes with UI metric P0 failures = 0.
