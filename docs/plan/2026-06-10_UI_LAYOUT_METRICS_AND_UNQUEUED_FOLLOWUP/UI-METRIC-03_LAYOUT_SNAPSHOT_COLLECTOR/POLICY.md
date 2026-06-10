# UI-METRIC-03 Policy

## Adopted Decisions

- Runtime snapshot collection is report infrastructure, not a product UI change.
- Snapshot data records visible Control state only.
- Scenario setup must include non-sample production states and an unconfigured state.
- JSON serialization must be stable enough for later tooling to parse.
- `tools/test.sh` should run the collector contract test because it is a command-only test path.

## Rejected Decisions

- Do not introduce metric pass/fail severity in this task.
- Do not depend on private node names for primary assertions.
- Do not use bundled sample assets as the only successful state.
- Do not mutate product UI solely to satisfy collector shape in this slice.

## Invariants

- Snapshot root can be any `Control`.
- Each collected entry describes one visible `Control`.
- Scroll parent data is structural evidence, not an acceptance gate by itself.
- Resource picker base type is observed when available and empty otherwise.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Empty `base_type` for non-picker controls | allow | Most Controls are not ResourcePickers. | None; evaluator handles picker-specific requirements later. | `tests/test_workspace_layout_metrics.gd`. |
| Report-only collector | allow | Severity policy is not part of this task. | `UI-METRIC-04` and gate tasks add scoring. | Standard test verifies collector contract only. |
| Synthetic scenario resources | allow | The test needs representative state without project files. | None; they are in-memory test fixtures, not sample production defaults. | Multi-scenario layout test. |
| Persistent JSON report file | defer | Report output location belongs to evaluator/test integration. | `UI-METRIC-07`. | Queue proof. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| No selected HexTileMap | Empty state text is visible and captured. | Collector misses first-impression no-target state. | `tests/test_workspace_layout_metrics.gd`. |
| Selected HexTileMap without resources | Unconfigured state can be built without samples. | Snapshot only proves a fully configured happy path. | `tests/test_workspace_layout_metrics.gd`. |
| Selected HexTileMap with shared resources | Ready-ish resource state can be built with in-memory project resources. | Collector misses ResourcePicker/base-type surfaces. | `tests/test_workspace_layout_metrics.gd`. |
| Multiple viewport sizes | Snapshot preserves viewport metadata. | Layout metric inputs are size-blind. | `tests/test_workspace_layout_metrics.gd`. |
| JSON output | Snapshot can be parsed by later tools. | Evaluator cannot consume collector output. | JSON parse assertion. |

## Resource / API / UI Boundary

- Addon testing helpers live under `addons/hex_map_kit/editor/testing/`.
- Product Workspace behavior is not changed by this task.
- The test owns scenario construction and collector contract assertions.
