# GQM-14 Result Resource Save/Switch — Policy

## Adopted Decisions

- A saved result resource writes only `result_id`, `seed`, `primary_map`, `overlay_maps`, `generation_snapshot`, and `metadata`.
- `overlay_map` may be populated only as a compatibility mirror of the first overlay when already derived from `overlay_maps`; park fields stay blank/default.
- Switching a saved result is a preview operation: it snapshots the current document, promotes saved data into generated layers, applies that document to the viewport, and leaves Apply/Revert enabled.
- The Results list uses `HexMapAssetLibrary` kind `results` and displays names only.

## Rejected Decisions

- Do not write `score`, `validation_result`, `validation_summary`, `score_row`, `source_snapshot`, `preview`, `candidate_document`, or `overlay_mode` as part of this feature.
- Do not call the graph runner when loading a saved result.
- Do not expose paths or raw JSON as normal result UX.
- Do not create thumbnail display.

## Resource / API / UI Boundary

| area | owns | must not own |
|---|---|---|
| `HexGenerationResultResource` | Clean construction from generated output and graph snapshot | Build-screen UI state or asset list selection |
| `HexMapAssetLibrary` | Project-layer save/list/load for kind `results` | Special result semantics |
| Build screen | Save dialog, result list, saved-result preview switching, Apply/Revert continuity | New generation algorithms or graph runner changes |
| Tests | Data-included save/load/switch/promote contract | Visual thumbnail or score contracts |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| `overlay_map` single-overlay field | keep as derived mirror only if first overlay exists | Existing resource shape has it, but canonical saved data is `overlay_maps` | Remove when legacy field is deleted from resource | Field-limited test asserts `overlay_maps` is populated and park fields remain blank/default. |
| Missing generated result on Save | visible blocked status | Saving nothing would create misleading empty assets | none | Test can inspect error result for no last Result output if added later. |
| Bundled results | list supports asset library but expected empty | Result assets are project output, not bundled presets | none | Snapshot/list verifies project result entry after save. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Generated graph result | Save copies data into resource, not references to transient runner cache only | Later graph changes could mutate saved result | Save/load equality test on map signature. |
| Saved result selected | Preview changes without calling graph runner | Regression into seed-only replay | Run count/progress/cache assertion and output identity test. |
| Preview pending | Apply/Revert semantics match generated preview | Switch could accidentally commit immediately | Build screen test checks `preview_pending`, Apply, Revert. |
| Promote from switched result | Generated layers are available for existing promote/apply path | Saved data could bypass document layer preparation | Promote test checks terrain/overlay document layers after switch. |
