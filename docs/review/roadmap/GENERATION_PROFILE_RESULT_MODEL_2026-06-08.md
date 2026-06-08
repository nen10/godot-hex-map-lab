# Generation Profile / Result / Document Model

Date: 2026-06-08

## Decision

Keep the current implementation behavior, but define the intended model boundary for future Resource/API work:

- **Generation Profile** is user-authored input configuration.
- **Generation Preview** is transient editor state.
- **Generation Result** is the future persisted intermediate output model.
- **Level Document** is the committed authoring resource used by Paint, Validate, QA promotion, and Runtime Handoff.

Graph editor UI remains out of scope until `GenerationProfileResource` and `GenerationResultResource` ownership, serialization, and replay behavior are implemented.

## Model Roles

| Model | Role | Current representation | Future representation |
|---|---|---|---|
| Generation Profile | Durable generation inputs: generator type, shape, seed policy, overlay options, query references, output defaults. | Flexible `Resource` slot / duplicated preset metadata. | `GenerationProfileResource`. |
| Generation Preview | Last generated primary/overlay data visible in Generate and target display. | `HexMapGenDock._current_data`, `_current_overlay_data`, `_last_generation_snapshot`, validation summary. | Still transient by default. |
| Generation Result | Persisted generated output and provenance before commit. | Not implemented; QA rows are transient summaries. | `GenerationResultResource` or equivalent subresource/artifact. |
| Level Document | Committed authoring map state. | `HexMapDocumentResource` terrain/overlay/object/label data plus metadata. | Same, with concise provenance reference/summary. |

## State Boundaries

```text
Generation Profile
  -> Generate
  -> Generation Preview
  -> optional future Generation Result
  -> Apply / Promote
  -> Level Document
```

### Generation Profile

Profile owns desired input configuration. It should not own generated cells. It may reference project assets such as Tile Catalog, validation suite, masks, source maps, or presets once those references have stable Resource/API contracts.

### Generation Preview

Preview is a disposable editor result. It may update target display and validation readbacks, but it is not a project asset and should not be treated as saved work.

Current behavior that matches this boundary:

- `Preview only` updates target display without changing the selected Level Document.
- `_last_generation_snapshot` is used as metadata source for a later apply.
- Validation is captured before auto-apply.

### Generation Result

Generation Result should be the future persisted intermediate model. It should store:

- result id / display name;
- source profile reference or embedded profile snapshot;
- seed and sanitized generation settings;
- primary `HexMapResource` data;
- optional overlay `HexOverlayResource` data;
- optional named intermediate maps such as region, biome, room, mask, or reference maps;
- validation summary and issue snapshot;
- created/updated timestamps;
- status: previewed, accepted, rejected, superseded, committed.

It should not be required for ordinary single-pass Generate usage.

### Level Document

The Level Document is the committed authoring resource. It should contain final terrain/overlay/object/label state and concise generation provenance, not a full graph.

Current metadata behavior is the right shape:

- `generation_seed`
- sanitized `generation_snapshot`
- `generation_source`
- `generation_output_target`
- `generation_validation_summary`
- optional QA score/batch index

Future work may replace or augment these with a `generation_result_path` / `generation_result_id` reference, but the document should stay usable without loading an editor graph.

## QA / Seed Lab Alignment

Current QA rows are candidate summaries. They are not durable results.

Future alignment:

- Each Seed Lab row may optionally create or point to a `GenerationResult`.
- Promotion copies selected result data into a Level Document.
- QA score, validation summary, and source seed should remain visible after promotion through document metadata.
- Rejecting a candidate should not mutate the Level Document.

## Intermediate Data Use Cases

| Use case | Model location | Notes |
|---|---|---|
| Primary terrain reused as overlay filter | Generation Result named map/reference. | Do not add another Generate tab section before result references exist. |
| Region / biome / room map | Generation Result intermediate map. | Needs type tags and validation. |
| Manual edit lock mask | Generation Profile input plus Generation Result provenance. | Needs merge policy and conflict reporting. |
| Overlay map generated from prior pass | Generation Result dependency. | Graph UI only after dependencies are serializable. |
| Final committed terrain | Level Document terrain layer. | Authoring data, not intermediate state. |

## Test Implications

No schema changed in this task, so no new runtime test is required.

When `GenerationProfileResource` or `GenerationResultResource` is implemented, tests should cover:

- Resource save/load roundtrip.
- Replay from profile without a live dock.
- Generation Result save/load with primary and overlay data.
- QA row promotion preserving result provenance.
- Applying a result to a selected Level Document without copying transient editor-only fields.
- Backward compatibility only if existing saved docs are explicitly in scope.

## Out Of Scope

- Graph editor UI.
- Visual pass nodes.
- Multi-result browser.
- Generation cache invalidation UI.
- Migration of existing documents.
