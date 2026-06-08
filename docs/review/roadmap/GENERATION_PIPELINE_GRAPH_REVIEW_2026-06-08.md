# Generation Pipeline Graph Review

Date: 2026-06-08

## Summary

Do not expand the current `Generate` tab into a graph editor yet. The current editor already has useful immediate UI for preview, validation, progress, output target, QA seed comparison, and applying/promoting results. Persistent intermediate generation data needs a Resource/API model first.

Recommended next design step: `GEN-81` should define the relationship between Generation Profile, Generation Result, preview state, intermediate state, and committed Level Document metadata before any graph UI is planned.

## Current Implementation Evidence

| Area | Current state | Implication |
|---|---|---|
| Generate preview | `HexMapGenDock` stores transient `_current_data`, `_current_overlay_data`, `_last_generation_snapshot`, and validation summary. | Preview is useful but not a durable project asset. |
| Output target | Generate distinguishes `Preview only` and `Apply to selected Document`. Applying writes generation metadata to the selected document. | Immediate UI distinction exists; persistence boundary is still document metadata. |
| QA Seed Lab | Batch rows are transient score/validation rows; promotion creates a `HexMapDocumentResource` with generation seed/snapshot metadata. | QA owns comparison UI; it should not become a graph editor. |
| Overlay generation | Overlay mode can use mask/reference/deductor query rows and external mapdata sources. | There is already graph-like dependency behavior, but it is control state, not a typed pipeline model. |
| Document commit | Committed results become terrain/overlay/object/label document resources plus metadata. | Final authoring state is clear; intermediate provenance is shallow. |

## Immediate UI

Keep these in the near-term Generate / QA UI:

- Preview-only generation result.
- Apply current generated result to selected Level Document.
- Validation summary before auto-apply.
- Progress/busy state for generation, validation, and apply.
- QA Seed Lab seed batch comparison and promotion.
- Clear output-target language: preview vs committed document.
- Concise metadata/status showing which generated result was applied.

Do not add new panels for these; the current tabs already have the correct homes.

## Backlog Resource/API Work

These should be backlog model work, led by `GEN-81`:

- `GenerationProfileResource`: durable generation parameters, seed policy, shape, overlay mode, query references, output target defaults.
- `GenerationResultResource`: generated primary map, overlay data, validation summary, source profile reference, seed, timestamp, and result status.
- Intermediate map/reference model: named primary, region, biome, room, mask, and overlay layers that can be referenced by later passes.
- Locked/manual-edit mask model: define how protected edited regions are represented and merged with regenerated regions.
- Provenance model: distinguish transient preview snapshot, persisted intermediate result, and committed `HexMapDocumentResource` metadata.
- API contract for replaying a profile/result without requiring a live dock.

This work may add Resource schemas and tests, but should still avoid graph UI until ownership and serialization are clear.

## Research Only

Keep these out of the current roadmap implementation until the model work exists:

- Node graph editor for generation passes.
- Visual edges between primary terrain, overlay filters, biome maps, and region maps.
- Arbitrary pass chaining and partial invalidation UI.
- Graph-level caching, dependency invalidation, and conflict resolution.
- Multi-result browser inside Generate.
- Editing intermediate maps as first-class authoring layers.

These are likely useful later, but adding them before a Resource model would bloat `Generate` and make save/load behavior ambiguous.

## Use-Case Classification

| Use case | Classification | Reason |
|---|---|---|
| Primary terrain map used as overlay filter | Backlog | Needs named intermediate/result references, not more Generate controls. |
| Region / biome / room map as intermediate data | Backlog | Needs typed intermediate map ownership and validation. |
| Lock manually edited regions and regenerate the rest | Backlog | Needs edited-region mask model and merge policy. |
| Manage generation parameters/pass results like nodes | Research | Requires Resource model first; graph UI later. |
| Chain overlay maps that use prior generated references | Research | Current overlay reference controls prove the need, but graph dependency semantics are undefined. |
| Separate final Level Document from intermediate data | Backlog | `GEN-81` should define preview/result/document boundaries. |

## Recommendation For GEN-81

`GEN-81` should produce a model document before implementation:

- Define Generation Profile, Generation Result, and committed Level Document roles.
- Define whether intermediate maps are Resources, subresources, document metadata, or external artifacts.
- Define how QA Seed Lab rows become or reference Generation Results.
- Define how `Apply to selected Document` records provenance without copying transient editor-only state.
- Define tests for serialization/reload and replayability.

Until that is complete, keep the current Generate tab focused on preview/apply/progress and QA focused on seed comparison.
