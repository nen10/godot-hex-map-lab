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

### GQM-01_CONSOLIDATED_NODE_ENGINE_AND_ADAPTATION

proof:
  review: `docs/review/autopilot/GQM-01_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-01_SELF_REVIEW_2026-07-03.md`
  tests:
    - `./tools/test.sh` (exit 0)
  acceptance:
    - `tests/test_generation_graph.gd` builds the R2-3 basic form as consolidated 7 node / 9 edge graph and compares Result substrate cells/walls plus overlay item cells against the legacy 15 node / 16 edge graph with the same seed.
    - `tests/test_generation_graph.gd` covers the adaptation matrix for terrain / overlay / selection / empty producers and floor / wall / any / cells / item adaptations.
    - `tests/test_generation_graph.gd` covers `would_create_cycle()` true and false cases.
    - `tests/test_generation_graph.gd` covers `normalize_graph()` parity for a straight legacy chain and the basic legacy graph.
  major files:
    - `addons/hex_map_kit/generation/hex_generation_adaptation.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph_normalizer.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph_runner.gd`
    - `tests/test_generation_graph.gd`
    - `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
