# Build Generate Viewport Preview Design Clarification

Date: 2026-06-22
Related handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
Related repair matrix: `docs/development_log/2026-06-22_BUILD_GENERATE_VIEWPORT_PREVIEW_REPAIR_MATRIX.md`

## Purpose

This document separates the product decision from implementation proof so Build Generate repair work does not confuse node preview data with the Godot viewport result.

The repair is not a Build tab redesign. It is a hotfix for the primary action: pressing `Generate` must make the generated map visible in the Godot 2D viewport through a real `HexTileMapLayer`.

## Corrected Clarification

The square tile panel was not the requested visible result and should not be treated as the Build completion surface.

`HexMapPreviewThumbnail` is a legacy/lightweight preview contract used by Generate/QA snapshot payloads and some older preview UI. It is not the Build viewport result. Build Generate completion proof must not be thumbnail-only, and the repair must not reintroduce a visible square thumbnail panel as the answer to Generate.

## Decided Behavior

| area | decision |
|---|---|
| Primary Generate result | Show the generated result in the Godot 2D viewport. |
| Target layer | Use selected `HexTileMapLayer`; if none exists, create and select `BuildHexMapLayer`. |
| Context dependency | Build screen must synchronously receive the active layer/document before running. |
| Preview commit model | Generated viewport result is pending until `Apply`; `Revert` restores the previous in-memory document and viewport display. |
| Thumbnail / square panel | Do not use as Build completion UI or proof. |
| Completion proof | Require viewport fields and layer display cells, not cache-only or thumbnail-only evidence. |

## Required Snapshot Proof

Build Generate proof must include:

- `viewport_preview_visible`
- `viewport_preview_layer_path`
- `viewport_preview_cell_count`
- `preview_commit_state`
- target layer `display_used_cell_count() > 0`

Thumbnail payloads, graph cache, and candidate preview snapshots may exist for other flows, but they do not prove Build Generate success.

## Rejected Proof

| rejected item | reason |
|---|---|
| Thumbnail-only preview | It can prove output data exists, but not that the user sees a map in the Godot viewport. |
| Sample-only success | Samples are onboarding assets, not production feature proof. |
| Graph cache-only tests | Cache state does not prove visible layer projection. |
| Visible square preview panel as Generate result | It competes with the required viewport-first first impression. |

## Remaining Follow-Ups

These are intentionally out of the hotfix patch:

- Graph-wide generation state model.
- Region Filter item-key UX.
- Graph canvas operability/layout.
- Edge deletion behavior.
- Broader Generate/QA thumbnail policy cleanup if the product direction is to remove those visible controls globally.

## Process Note

The implementation plan contained an ambiguity: "keep thumbnail as secondary" conflicted with the need to avoid reintroducing or legitimizing the square tile panel as Build completion UI. The correct design process is to resolve that ambiguity in this document before treating implementation proof as complete.
