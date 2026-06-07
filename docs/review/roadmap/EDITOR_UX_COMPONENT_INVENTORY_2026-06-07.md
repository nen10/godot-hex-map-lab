# Editor UX Component Inventory 2026-06-07

作成日: 2026-06-07
Task: `CLEAN-30`
Roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`

## Summary

現在の editor UI は `HexMapGenDock` と `HexMapEditTool` を中心に、生成、保存、paint、catalog key、object、validation、target setup、debug report が混在している。分類根拠は file size ではなく、ユーザーが達成したい作業目的である。

この inventory の結論:

- Generate の seed / shape / generator pipeline は `keep-in-place`。
- Document 操作は Edit Dock 内の path text から `Document Header` へ `move-to-screen` / `merge-with-existing`。
- Catalog は brush selector としては維持するが、resource / entry / preview 画面がないため `Catalog Screen` へ `move-to-screen`。
- Layer Stack は backend と tests があるが editor screen がないため `Layer Stack Screen` へ `move-to-screen`。
- Validation は component 化済みだが Edit Dock 内にあるため `Validate Screen` へ `move-to-screen`。
- QA batch / score / promotion は API と tests があり、screen workflow がないため `Seed Lab / QA Screen` へ `move-to-screen`。
- editable path text、numeric fallback controls、legacy migration hooks、plain TileMapLayer primary apply は後続 CLEAN task の explicit deletion / advanced-only 候補である。

## Classification Vocabulary

| Classification | Meaning |
|---|---|
| `keep-in-place` | 現画面の作業目的に合う。後続 redesign でも同じ screen に残す。 |
| `move-to-screen` | 機能は有用だが、現在の画面とは別の作業目的に属する。 |
| `merge-with-existing` | 同じ作業目的が複数箇所に分散しているため統合する。 |
| `advanced-only` | 通常 UX には不要だが debug / support / generator tuning に残す余地がある。 |
| `delete` | path text、legacy、fallback、raw internal value 由来で通常 UX から消す。 |

## Source Inventory

| User task | Current UI / code | Evidence | Classification | Follow-up owner |
|---|---|---|---|---|
| Document select/load/save/status | Edit Dock has `EditorResourcePicker`, document path `LineEdit`, `Browse`, `Load`, `Save As`, plus `Document Inspector`. Session state persists path strings. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:759-786`, `addons/hex_map_kit/editor/hex_map_document_inspector.gd:24-35`, `addons/hex_map_kit/editor/hex_map_editor_session_state.gd:7-12` | `move-to-screen` + `merge-with-existing` | `CLEAN-21` Document Header |
| Editable document path | `_document_path_edit` is a normal editable `LineEdit`. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:768-773` | `delete` | `CLEAN-20`, `CLEAN-21`, `CLEAN-33` |
| Import / export resource paths | Import and export are editable path rows in the main Edit Dock. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:788-818` | `delete` for editable path; `move-to-screen` for actions | `CLEAN-20`, `CLEAN-21`, `CLEAN-33` |
| Legacy document migration entry | Edit Dock converts non-v2 documents with `migrate_v1_to_v2()`. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:234-239` | `delete` | `CLEAN-10`, `CLEAN-11`, `CLEAN-33` |
| Generate target selection | Generate Dock target layer selector and refresh are part of generation/apply workflow. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:299-309` | `keep-in-place`, later share with Layer Stack | `CLEAN-24`, `CLEAN-32` |
| Generate seed / shape / generator pipeline | Generate Dock owns shape, connection, overlay mode, seed, progress, and generation actions. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:314-405`, `addons/hex_map_kit/editor/hex_map_gen_dock.gd:774-808` | `keep-in-place` | `CLEAN-25`, `CLEAN-32` |
| Generate save/apply actions | Generate Dock has `Apply Layer` and `Save As .tres`. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:460-472` | `advanced-only` for plain apply; `move-to-screen` for save/export | `CLEAN-21`, `CLEAN-24`, `CLEAN-33` |
| Generate overlay source/query controls | Overlay target item, source registry, query cell settings, placement mask, deductor floor, adjacency reference are inside Generate Dock. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:487-647` | `advanced-only` unless surfaced by Generate/QA workflow | `CLEAN-25`, `CLEAN-32` |
| Source registry resource loading | Source registry uses browse dialog and resource path status. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:546-568`, `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1350-1363` | `advanced-only` | `CLEAN-25`, `CLEAN-33` |
| Paint/edit target and mode | Edit Dock owns target selector and edit mode, matching Paint / Edit workflow. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:820-838` | `keep-in-place` | `CLEAN-32` Brush Palette |
| Brush mutation logic | Mutation builder centralizes Shape / Wall / Floor Tile / Wall Tile / Object / Label / Overlay edit payload application. | `addons/hex_map_kit/editor/hex_map_edit_mutation_builder.gd:7-24`, `addons/hex_map_kit/editor/hex_map_edit_mutation_builder.gd:127-160` | `keep-in-place` as Paint/Edit model helper | `CLEAN-32` Brush Palette |
| Default target tile catalog selection | Edit Dock has Floor / Wall catalog options for defaults. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:840-850` | `keep-in-place` as brush default selector | `CLEAN-22`, `CLEAN-32` |
| Default target numeric tile controls | Floor / Wall source, atlas X/Y, alt are normal Edit Dock controls. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:851-879` | `delete` from normal view, maybe `advanced-only` debug | `CLEAN-20`, `CLEAN-33` |
| Target TileSet / atlas setup | Edit Dock has TileSet picker plus editable atlas image path and sample apply. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:892-929` | `move-to-screen`; atlas path `LineEdit` is `delete` | `CLEAN-20`, `CLEAN-22`, `CLEAN-33` |
| Tile paint catalog key | Edit Dock has tile catalog option for Floor/Wall/Overlay brush modes. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:931-933` | `keep-in-place` | `CLEAN-22`, `CLEAN-32` |
| Tile paint numeric payload | Tile source / atlas / alternative spins are normal paint controls. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:934-947` | `delete` from normal view, maybe `advanced-only` in Catalog detail/debug | `CLEAN-22`, `CLEAN-33` |
| Overlay item key | Edit Dock has raw overlay item key text plus known option. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:949-959` | `merge-with-existing`; raw text becomes `advanced-only` | `CLEAN-22`, `CLEAN-32`, `CLEAN-33` |
| Object placement selector | Edit Dock has Object Catalog option and Object DB picker. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:961-981` | `move-to-screen` / `merge-with-existing` | `CLEAN-23`, `CLEAN-32` |
| Raw object id | `_object_id_edit` exposes object id text as normal UI. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:961-967` | `delete` from normal view | `CLEAN-23`, `CLEAN-33` |
| Object properties | Edit Dock has JSON-like properties `LineEdit` and a read-only-ish property table. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:982-993` | `move-to-screen`; raw text is `delete`, table concept is `keep` | `CLEAN-23` |
| Object rotation / variant / spawn | Rotation SpinBox is useful; variant/spawn are raw text. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:968-997` | `move-to-screen`; raw spawn text becomes `advanced-only` or typed UI | `CLEAN-23` |
| Label placement controls | Label id/text and Label DB picker are in Edit Dock. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:999-1012` | `move-to-screen` / `merge-with-existing` | `CLEAN-14`, `CLEAN-32` |
| Validation dashboard | Dedicated component has Validate button, summary, sortable issue rows, selected issue signal. It is embedded in Edit Dock. | `addons/hex_map_kit/editor/hex_map_validation_dashboard.gd:83-149`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1023-1026` | `move-to-screen` with component reuse | `CLEAN-26`, `CLEAN-32` |
| Validation focus | Edit Dock can select validation issues and focus cell-scoped issue state. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:395-418`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:2551-2572` | `keep-in-place` behavior; move UI to Validate screen | `CLEAN-26` |
| Copy Debug Report | Edit Dock has debug report button and verbose status strings. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:1027-1030`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:2589-2618` | `advanced-only` support action | `CLEAN-26`, `CLEAN-40` |
| Catalog editing screen | No current editor screen for catalog resource, TileSet picker, entry list, preview, tags, scene entry picker. Current UI only selects keys from sample/current catalog. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:920-995`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:3021-3050` | `move-to-screen` missing capability | `CLEAN-22` |
| Catalog fallback label/config | Both docks define `Advanced numeric fallback`; adapters still accept fallback config. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:95-96`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:29-30`, `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1033-1051` | `delete` from normal UX | `CLEAN-11`, `CLEAN-13`, `CLEAN-33` |
| Catalog compatibility warnings | Edit Dock target status reports catalog fallback warnings. | `addons/hex_map_kit/editor/hex_map_edit_tool.gd:2494-2506` | `delete`; missing assignment becomes validation issue | `CLEAN-11`, `CLEAN-33` |
| Generate tile settings numeric fallback | Generate Dock Tile Settings has catalog options but also floor/wall numeric source and atlas spins. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:811-879` | `delete` from normal view, maybe `advanced-only` Catalog detail/debug | `CLEAN-22`, `CLEAN-33` |
| Overlay item pool numeric fallback | Overlay item rows combine catalog option with source/atlas spins and fallback config. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:1682-1800` | `delete` from normal view | `CLEAN-13`, `CLEAN-22`, `CLEAN-33` |
| QA batch / score / promote | Generate Dock exposes batch, score table, and promotion APIs, but no first-class screen rows for comparing and promoting seeds. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2360-2458`, `tests/test_editor_plugin.gd:2577-2666` | `move-to-screen` | `CLEAN-25`, `CLEAN-32` |
| Layer Stack authoring | Layer stack backend and tests exist, but no editor screen exposes template picker, roles, visible/locked/z-index, create missing layers, or clear role. | `tests/test_hex_tile_map_layer.gd:297-412`, `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:286-328`, `addons/hex_map_kit/adapter/hex_tile_map_layer.gd:1658-1678` | `move-to-screen` missing capability | `CLEAN-24`, `CLEAN-31`, `CLEAN-32` |
| Plain TileMapLayer primary path | Generate/Edit still surface generic TileMapLayer apply and numeric tile setup as normal target workflow. | `addons/hex_map_kit/editor/hex_map_gen_dock.gd:2107-2131`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:2141-2209` | `advanced-only` or `delete` as primary UX | `CLEAN-24`, `CLEAN-33` |
| Document summary/status | DocumentInspector summarizes cells/walls/objects/labels/path and validation. | `addons/hex_map_kit/editor/hex_map_document_inspector.gd:114-150` | `merge-with-existing` into Document Header | `CLEAN-21`, `CLEAN-26` |
| Session state | Session state shares target/document/path across Generate/Edit. | `addons/hex_map_kit/editor/hex_map_editor_session_state.gd:7-12`, `addons/hex_map_kit/editor/hex_map_gen_dock.gd:262-264`, `addons/hex_map_kit/editor/hex_map_edit_tool.gd:201-212` | `merge-with-existing`; path strings become saved status only | `CLEAN-20`, `CLEAN-21` |
| Generate state evaluator | Pure helper owns visibility and disabled state for Generate controls. | `addons/hex_map_kit/editor/hex_map_gen_state_evaluator.gd:8-60` | `keep-in-place` helper, reusable during extraction | `CLEAN-32` |

## Screen-Level Target Map

| Future screen / component | Keep / move into it | Remove from normal route |
|---|---|---|
| Document Header | Document resource picker, New/Open/Save/Save As, dirty state, document summary, validation summary | editable document path, v2/migration wording |
| Generate | Shape, seed, generator mode, overlay generation controls, progress/cancel | plain TileMapLayer primary apply, numeric tile defaults as normal controls |
| Paint / Edit | Target viewport edit, edit mode, brush key selection, last edit trace | raw source/atlas tile payload in normal brush |
| Catalog | Catalog resource picker, TileSet picker, entries, preview, tags, scene entry picker | fallback fields as normal authoring surface |
| Object Palette | Object database picker, definition list, object key brush, typed properties | raw object id, raw dictionary text |
| Layer Stack | Template picker, role rows, visible/locked/z-index, create missing layers, apply document, clear role | plain single-layer path as primary route |
| Validate | Grouped issues, severity, focus, fix suggestions, concise summary | verbose debug status in normal area |
| Seed Lab / QA | Batch run controls, score table, selected seed preview, promote to document | QA remaining as API-only workflow |
| Runtime / Export | Runtime sample/export/package handoff, support debug report | editable export path as primary input |

## Explicit Deletion Candidates

These are candidates for `CLEAN-20`, `CLEAN-21`, `CLEAN-22`, `CLEAN-23`, `CLEAN-33`, and canonical resource tasks. They should not be preserved only because existing headless tests assert them.

- `HexMapEditTool._document_path_edit`: editable document path.
- `HexMapEditTool._import_map_path_edit`: editable import path.
- `HexMapEditTool._export_path_edit`: editable export path.
- `HexMapEditTool._target_atlas_path_edit`: editable atlas image path.
- `HexMapEditTool._default_floor_source_spin`, `_default_floor_atlas_x_spin`, `_default_floor_atlas_y_spin`, `_default_floor_alternative_spin`.
- `HexMapEditTool._default_wall_source_spin`, `_default_wall_atlas_x_spin`, `_default_wall_atlas_y_spin`, `_default_wall_alternative_spin`.
- `HexMapEditTool._tile_source_spin`, `_tile_atlas_x_spin`, `_tile_atlas_y_spin`, `_tile_alternative_spin` in normal paint UI.
- `HexMapEditTool._object_id_edit`, `_object_properties_edit`, `_object_spawn_condition_edit` as raw text normal UX.
- `HexMapEditTool._document_for_editor()` v1 -> v2 migration path.
- `HexMapEditTool._catalog_compatibility_warnings_for_status()`.
- `HexMapGenDock.CATALOG_FALLBACK_LABEL` and `HexMapEditTool.CATALOG_FALLBACK_LABEL`.
- `HexMapGenDock` floor/wall source and atlas spins in Tile Settings.
- `HexMapGenDock` overlay item source and atlas fallback spins.
- plain `TileMapLayer` apply as the primary happy path.

## Follow-up Connections

| Follow-up task | Inventory dependency |
|---|---|
| `CLEAN-10` | Delete v1/v2 vocabulary and migration UI hooks identified here. |
| `CLEAN-20` | Replace editable path text with ResourcePicker / FileDialog / read-only saved status. |
| `CLEAN-21` | Build Document Header from document picker, save actions, inspector summary, validation summary. |
| `CLEAN-22` | Build Catalog Screen and leave Paint/Generate with catalog key selectors only. |
| `CLEAN-23` | Build Object Palette and type-aware property editor. |
| `CLEAN-24` | Build Layer Stack Screen because no editor screen exists yet. |
| `CLEAN-25` | Turn batch/score/promotion API into visible Seed Lab workflow. |
| `CLEAN-26` | Move/refine Validation component into issue-focused screen. |
| `CLEAN-31` | Use this inventory to decide 2-dock vs workspace/tab model. |
| `CLEAN-32` | Extract components by these UX responsibilities, not by file size. |
| `CLEAN-33` | Delete or advanced-only the explicit harmful UI paths. |

## Test Notes

No tests were added or changed for this inventory. Current headless tests still cover the old UI and are evidence of existing contracts, not a reason to preserve those contracts during CLEAN implementation.
