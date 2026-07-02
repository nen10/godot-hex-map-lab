# Proof Log — GQM track

Queue: `IMPLEMENTATION_QUEUE.md`（本 dir）。Entry 形式は `docs/process/QUEUE_OPERATION_RULES.md` に従う。

### GQM_DESIGN_LOCK_2026-07-03

proof:
  design:
    - `DESIGN_DIALOGUE.md`（round 1-3 + 確定記録）
    - `RESOURCE_MODEL.md`（Q-RM-1..3 確定）
    - `DEPENDENCY_UX_PROPOSALS.md`（round 1-4。統合4ノード・無型edge・adaptation・Q-DEP 全確定）
  godot_feasibility:
    - GraphEdit / GraphNode stable class docs 確認（same-type 接続規則 / connection_request 委譲 / 循環防止なし / 子Control=slot行 / titlebar 拡張）— `DEPENDENCY_UX_PROPOSALS.md` R3-3
  decision:
    - 旧 queue `REPAIR-21` は `GQM-03` に吸収（SUPERSEDED）。`REPAIR-22` は既に SUPERSEDED、`REPAIR-23` は tail BACKLOG。

### GQM-02_ASSET_TWO_TIER_SERVICE_AND_RESOURCES

proof:
  implementation:
    - Added `HexMapAssetLibrary` as the generic two-tier asset service for bundled read-only presets and project assets under `hex_map_kit/asset_root`.
    - Migrated `HexAdjacencyRulePresets` to the service and kept existing bundled adjacency presets visible through the legacy bundled directory alias.
    - Added `HexItemPoolResource` with `display_name` and normalized `name` / `weight` / `limit` entries.
    - Extended `HexWallDistributionResource` with `display_name` and `from_preset(11/20/24)` initialization from `HexRandomizer` built-in weight arrays.
    - Added a minimal adjacency-rule dialog callsite update for source labels, project save, and duplicate-to-project.
  tests:
    - `tests/test_generation_graph_resource.gd` covers bundled/project integrated listing, source distinction, bundled write rejection, project root setting changes, duplicate-to-project, V5 graph save/load params, item pool `.tres` round-trip, wall distribution `.tres` round-trip, and preset weight equivalence.
    - `./tools/test.sh` passed with exit `0` after regenerating ignored local Godot imports; run id `20260703-062141-16845`.
    - UI metric report `.godot_user/ui-metrics/20260703-062141-16845/workspace_layout_metrics.md`: P0 `0`, P1 `0`.
  self_review:
    - `docs/review/autopilot/GQM-02_SELF_REVIEW_2026-07-03.md`
