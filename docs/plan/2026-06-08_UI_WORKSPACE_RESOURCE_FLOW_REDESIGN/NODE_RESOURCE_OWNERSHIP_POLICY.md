# HexTileMap Resource Ownership Policy

作成日: 2026-06-08
Task: `NODE-20`
Roadmap: `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`

## Summary

The roadmap says `HexTileMap` as the user-facing authoring-node concept. The current implementation class is `HexTileMapLayer`, a `Node2D` that owns runtime/display map state and can apply a canonical `HexMapDocumentResource`.

Resources tab grouping should use this ownership model:

```text
Selected HexTileMap
  UniqueResource:
    Level Document
    Node Layer Stack Instance
  OptionalResource:
    Runtime Initial Map / Generated Snapshot

Shared Project Resources:
  TileSet
  Tile Catalog
  Object Database
  Label Database
  Movement Profile

Feature Profiles:
  Generation Profile
  Validation Rule Suite
  Export Profile
```

The selected node should not silently receive bundled samples or auto-created shared resources. Missing unique resources should be visible and creatable through a deliberate flow.

## Source Notes

| Source | Current fact |
|---|---|
| `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` | Current authoring/runtime node class is `HexTileMapLayer`. |
| `HexTileMapLayer.hex_map` | Exported `HexMapResource` used as runtime/display map data. |
| `HexTileMapLayer.display_tile_set_resource` | Exported `TileSet` used for display. It is visual support, not the authoring catalog. |
| `HexTileMapLayer.layer_stack_resource` | Exported `HexLayerStackResource` used by `apply_document_to_layer_stack()`. |
| `HexTileMapLayer.load_document_resource()` | Applies a `HexMapDocumentResource` to the node but does not store the document as an exported node reference. |
| `HexTileMapLayer.to_document_resource()` | Can derive a document from current node state. This is export/serialization support, not proof that the node owns a selected project document. |
| `HexMapWorkspaceAssetContext` | Current shared editor context stores Level Document, Tile Catalog, Layer Stack, Object DB, Label DB, Movement Profile, Validation Suite, Generation Profile, Export Profile. |
| `HexMapWorkspaceAssetResourceFactory` | Current factory can create all workspace slot resources, with Generation/Validation/Export profiles still generic `Resource`. |
| `HexMapDocumentResource.dependencies` | Canonical document can carry dependency resources such as catalog/object/label databases. |
| `HexMapDocumentAdapter.apply_to_tile_map_layer()` | Rendering needs a Tile Catalog / TileSet context, but missing catalog assignment should remain validation state rather than numeric fallback. |
| `HexMapEditTool.set_workspace_asset_context()` | Paint/Edit consumes shared context for catalog, object database, label database, and layer stack. |

## Classification

| Resource | Classification | Node ownership | Required for selected node? | Display guidance |
|---|---|---|---|---|
| Level Document | UniqueResource | Belongs to selected HexTileMap authoring node. | Required for production authoring, unless the node is intentionally unconfigured. | Top selected-node group. Missing state should be visible. |
| Node Layer Stack Instance | UniqueResource | Belongs to selected node because child role nodes, visibility, z order, and writable state are node-specific. | Required when layered authoring/apply is used; can be missing for simple runtime preview. | Top selected-node group, but clearly optional until layer workflow starts. |
| Runtime Initial Map / `HexMapResource` snapshot | OptionalResource | Derived or runtime state on the node. | Not required as authoring source. | Show as optional generated/runtime state, not as replacement for Level Document. |
| TileSet | SharedResource | Shared visual asset referenced through catalog/display setup. | Required only when visual rendering needs it. | Shared project resource, normally under Tile Catalog detail. |
| Tile Catalog | SharedResource | Project/library resource used by Generate, Paint, Validate, and apply paths. | Required for tile assignment workflows. | Shared project group; never silently sample-selected. |
| Object Database | SharedResource | Project/library resource for object definitions. | Required only for object placement workflows. | Shared project group or Paint summary. |
| Label Database | SharedResource | Project/library resource for label definitions/styles. | Required only for label placement workflows. | Shared project group or Paint summary. |
| Movement Profile | SharedResource / OptionalResource | Project gameplay rules, not node identity. | Optional unless movement/path validation is active. | Shared project group or Validate/settings detail; not top selected-node requirement. |
| Generation Profile | SharedResource / OptionalResource | Project generation parameters, not node identity. | Optional unless Generate/QA uses it. | Generate/QA context, not selected-node top group. |
| Validation Rule Suite | SharedResource / OptionalResource | Project validation policy, not node identity. | Optional unless custom validation is active. | Validate/QA context, not selected-node top group. |
| Export Profile | SharedResource / OptionalResource | Project export preset, not node identity. | Optional unless Export uses it. | Export context, not selected-node top group. |

## Noisy Always-On Resources

These resources should not appear as mandatory top-level selected-node setup:

- `Movement Profile`: useful for gameplay/path and validation, but many map-authoring flows do not need it immediately.
- `Generation Profile`: belongs to Generate/QA work, not selected-node identity.
- `Validation Rule Suite`: belongs to Validate/QA work, not selected-node identity.
- `Export Profile`: belongs to Export work, not selected-node identity.
- `TileSet`: important, but most users should think in terms of Tile Catalog first. TileSet can be shown as catalog dependency/detail.
- Runtime/debug numeric fallback settings: debug-only and not part of ownership.

## Resources Tab Display Model

The future Resources tab should show:

```text
Selected HexTileMap
  Node: <selected node path> / No HexTileMap selected
  Auto-link: On

Unique resources
  Level Document
  Layer Stack for this node

Optional node state
  Runtime Initial Map / Generated Snapshot

Shared project resources
  Tile Catalog
  Object Database
  Label Database
  Movement Profile

Feature profiles
  Generation Profile
  Validation Rule Suite
  Export Profile
```

Rules:

- No selected node blocks node-owned writeback and creation, with a visible reason.
- Selecting or creating a UniqueResource should write to the selected node once `NODE-23` implements writeback.
- Selecting a SharedResource should update workspace context and relevant document dependencies; it should not create a node-specific copy by default.
- Sample candidates may be visible for learning/duplication but never fill missing node-owned resources silently.

## Current Implementation Gaps

These are intentional follow-up inputs:

- `HexTileMapLayer` does not currently export a `level_document` reference. `NODE-21` / `NODE-23` must decide whether to add one or bridge through scene metadata/session state.
- `HexTileMapLayer` has `layer_stack_resource`, but the workspace context also stores `layer_stack`; `NODE-23` must define writeback precedence.
- Workspace asset context stores all resources in one flat object; `TAB-50` should regroup the display without necessarily changing the context storage.
- Generation/Validation/Export profiles are generic `Resource` today; `ASSET-30` should either introduce strict resource types or document why generic remains acceptable.
- `HexMapResource` is still an exported node field. It should be treated as runtime/display snapshot unless `NODE-24` explicitly defines a committed generation-result relationship.

## Completion Implications

For later tasks, feature completion requires one of:

- The selected node has the required UniqueResource.
- The workspace visibly says the selected node is missing that UniqueResource.
- The resource is classified as shared/optional and the relevant feature tab owns its missing state.

Sample preset success alone is not completion proof.
