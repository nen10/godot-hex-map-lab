# Workspace State Matrix

Source roadmap: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
UI contract: `docs/ui/WORKSPACE_UI_CONTRACT.md`
Metric policy: `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`

This document defines Workspace states for later layout snapshot and state contradiction metrics. Each state has expected visible output and forbidden visible output. The matrix is a contract; it is not proof that current UI already satisfies every row.

## State Source Rule

Metric scenarios should use ViewState/state models where possible. Tests should not infer state from private widget shape or debug labels.

| area | state source |
|---|---|
| Root/tab dispatch | `HexMapWorkspaceRootState`, `HexMapWorkspaceDispatcher` |
| Resources/binding | `HexMapWorkspaceBindingService`, `HexMapEditorAssetSlotState` |
| Generate | `HexMapGenerationRunState` and Generate output target ViewState |
| Paint | `HexMapPaintInteractionState` |
| Validate | `HexMapValidationWorkflowState` |
| QA | QA screen snapshot plus generation/profile state |
| Export | `HexMapExportWorkflowState` |
| Settings/Samples | `HexMapSampleLearningState`, Settings preferences ViewState |

## Matrix

| state id | input summary | primary tabs | expected visible output | forbidden visible output | state sources |
|---|---|---|---|---|---|
| `no_selected_hex_tile_map` | No `HexTileMapLayer` or compatible internal display layer is selected. | Resources, Generate, Paint, Validate, Export | Resources shows no selected map / choose or select target state; Generate/Paint/Export show target not ready; required project asset rows may stay visible as setup context. | sample catalog auto-selected; stale node name/path from previous selection; Generate/Paint ready state; enabled Apply/Export to selected document. | Root state, binding service |
| `selected_hex_tile_map_no_resources` | A target node is selected but Level Document, Layer Stack, Tile Catalog, Object DB, Label DB, and profiles are missing or unselected. | Resources, Generate, Paint, Validate | Resources shows selected target summary and missing unique/shared resource groups; Create Missing Resources is blocked until save directory if needed; Generate/Paint/Validate show missing document/catalog/profile routes. | Ready/clean state; sample source satisfying missing production assets; raw node path as primary label; no-op Create/Open/Validate buttons. | Binding service, asset slot state |
| `selected_hex_tile_map_with_unique_resources` | Selected node has node-owned Level Document and Layer Stack, but shared dependencies may still be missing. | Resources, Layers, Paint | Resources shows Level Document/Layer Stack readiness; Layers shows role relationship; Paint can show document target but missing brush/catalog if applicable. | Treating node-owned resources as shared project defaults; hiding missing shared dependency warnings; raw writeback map. | Binding service, asset slot state, layer ViewState |
| `selected_hex_tile_map_with_shared_resources` | Selected node/workspace has project Tile Catalog, Object DB, Label DB, Movement Profile, and profiles assigned manually or through context. | Resources, Catalog, Paint, Validate, QA, Export | Shared project Resources show project/source badges; Catalog/Paint/Validate/QA/Export can consume the relevant dependencies. | Direct bundled sample source without warning; generic `Resource` picker for required slot; path-first labels. | Asset context, asset slot state |
| `selected_hex_tile_map_with_document_dependencies` | Level Document dependencies hydrate Workspace asset context. | Resources, Catalog, Validate, QA, Export | Rows show Document Dependency source badge; missing dependency remains missing/invalid; manual project override stays selected when present. | Hydration overwrites manual override; missing dependency replaced by sample fallback; dependency id/raw JSON visible in normal UI. | Binding service, dependency service, asset slot state |
| `sample_mode_off` | Sample learning disabled or not active for main flow. | Settings, Resources, Catalog, Generate, Paint | Settings shows sample learning off/unavailable state; main selectors prioritize project Resources; Generate/Paint do not use bundled samples. | sample candidates in main production selectors; sample source satisfying required asset; sample path as primary visible label. | Sample learning state, asset slot state |
| `sample_mode_on` | Sample learning enabled explicitly. | Settings, Resources, Catalog | Settings shows learning state and duplicate-to-project action; any sample candidate is marked sample/learning; project Resource remains production path. | silent sample injection into Generate/Paint; sample mode shown as production readiness; sample path as primary visible label. | Sample learning state, asset slot state |
| `sample_resource_selected` | User directly selects or applies a bundled sample source. | Settings, Resources, Catalog | Row shows sample/warning source state and route to duplicate to project; production flow remains blocked until project copy selected. | treating sample as `SOURCE_PROJECT`; Generate/Paint using sample silently; sample-only completion proof. | Asset slot state, sample duplicator |
| `manual_project_resource_selected` | User selected a project Resource manually while document dependencies also exist. | Resources, Catalog, Validate, QA, Export | Row shows Manual Override or project source state; hydration does not replace it; clear/reselect path is explicit. | silent writeback/replacement by dependency hydration; hidden source precedence; raw dependency id text. | Binding service, asset slot state |
| `generate_preview_only` | Generate has a candidate/preview result but target document is not mutated. | Generate, QA | Generate shows preview/candidate summary and Apply/Promote target distinction; document dirty state remains unchanged. | visible text implying document was saved/applied; hidden preview/document boundary; sample-only preview completion. | Generation run state, output target ViewState |
| `generate_apply_to_document_dirty` | Generated result has been applied/promoted to selected Level Document and document is dirty. | Generate, Resources, QA | Generate/QA show applied/promoted result; Resources or document status shows dirty/needs save; Save path is explicit. | Saved/clean status while dirty; Apply button enabled as if no target result exists; raw generation snapshot as primary UI. | Generation run state, document state, output target ViewState |
| `generate_running_busy` | Generation is running, preparing, cancelling, or applying heavy tile settings. | Generate | Progress/busy/cancel state visible; conflicting Generate/Apply actions disabled with blocked reason; heavy update reason is understandable. | enabled conflicting primary actions; no progress/busy state; private `_generation_*` flag names. | `HexMapGenerationRunState` |
| `paint_no_brush` | Paint target exists but no active brush/catalog/object/label source is usable. | Paint, Catalog, Resources | Paint shows missing active brush or missing asset route; routes to Catalog/Resources owner components; viewport edit is blocked with reason. | editable-ready state; raw payload controls; catalog management controls inside Paint. | Paint interaction state, asset context |
| `paint_active_brush` | Paint has active target, document, layer, brush, and selected/hovered cell context. | Paint | Brush mode/key, target layer, selected/hovered cell, and last edit summary visible; viewport edit feedback syncs. | stale selected cell after target change; raw internal tile ids; missing target warning while target ready. | Paint interaction state, viewport adapter |
| `validation_no_issues` | Validation ran and returned clean or warnings below blocking threshold. | Validate, Resources | Validate shows clean/ok summary and last run context; issue list is empty or nonblocking warnings are clear. | stale error count; raw validation result dump; focus action with no selected issue. | Validation workflow state |
| `validation_with_errors` | Validation found blocking or warning issues. | Validate, Resources, Catalog, Paint, Layers, Export | Issue severity/count rows visible; each issue has owner/focus route and user-facing suggestion; selected issue routes to screen/resource/cell. | only raw rule ids/object dump; issue actions that do nothing; clean status contradiction. | Validation workflow state, issue navigator |
| `qa_no_profile` | QA/Seed Lab lacks Generation Profile or required validation/profile context. | QA, Resources | QA shows missing Generation Profile and routes to profile row; seed lab run is disabled with blocked reason. | enabled Run Seed Lab without profile; sample profile as silent default; raw profile path primary label. | QA ViewState, asset slot state |
| `qa_with_score_rows` | QA has generated/batch seed rows and selected seed context. | QA, Generate | Score rows, selected seed, validation status, promotion target, and preview availability are visible. | raw batch row dictionaries; promotion target hidden; selected seed and preview disconnected. | QA ViewState, generation state |
| `export_no_destination` | Export has document/profile context but no valid destination. | Export | Destination missing state visible; Choose Destination/use recent action shown when valid; Export disabled with tooltip reason. | enabled Export with empty destination; full path as primary text; unsupported package/upload controls. | Export workflow state |
| `export_ready` | Export has Level Document, Export Profile, and valid destination. | Export, Resources | Runtime handoff output type, readiness, destination summary, and Export action visible; last result shown after export. | debug/raw export result as normal UI; package upload as implicit action; stale not-ready message. | Export workflow state |
| `settings_debug_off` | Debug preference disabled. | Settings, all tabs | Settings shows debug off via checkbox/toggle; normal tabs show no debug payload labels. | redundant `false` status text; debug payload/path labels in normal UI; hidden debug mode still affecting main flow. | Settings preferences state |
| `settings_debug_on` | Debug preference enabled explicitly. | Settings, all tabs | Settings shows explicit debug on state; debug report/copy flow may include internal detail. | debug payload always visible in normal tabs; private flag/raw JSON labels outside debug report; normal UI relies on debug text. | Settings preferences state, debug report state |

## State Contradiction Checks

Later metric evaluation should flag any of these as contradictions:

- selected target exists, but normal UI says no target is selected
- required project Resource is missing, but Generate/Paint/Export appears ready
- sample mode off, but Generate/Paint/Catalog uses bundled sample source
- manual project override exists, but hydration display replaces it without user action
- Generate preview exists, but Level Document is shown as mutated/saved
- document dirty is true, but visible document status says saved/clean
- export destination is empty, but Export is enabled
- validation result has blocking issues, but Validate shows clean
- debug setting off, but debug labels are visible in normal UI

## Update Rule

When a future task adds a new root state, screen ViewState, or metric scenario, it must update this matrix and record the reason in that task's self-review.
