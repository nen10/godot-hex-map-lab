# GQM-17 Criteria Window DoD Self Review

Task: `GQM-17_CRITERIA_WINDOW_DOD`
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/GQM-17_CRITERIA_WINDOW_DOD/`

## Execution Summary

Completed the criteria-window DoD pass. The Adjacency all-white pattern finding was a probe mistake: the probe used handwritten direction keys in the wrong mental order. The probe now derives keys from `HexVector.directions()` and the rendered window shows black reference toggles plus component labels.

The Markov `1.0` finding was treated as a possible max-range defect, not as an integer-format issue. The probe logs all 15 Markov weight SpinBoxes as `min=0.0 max=8.0 step=0.5` and captures a visible `8.0` value. Product Markov semantics were left unchanged.

After corrected probe evidence, the remaining product-side DoD issue was Adjacency window ergonomics: the rule-set name field opened truncated and the initial dialog was wider than the 1200x860 verification viewport. The fix gives the name field usable width and opens the dialog at a smaller 5-card initial layout while preserving resizability and the existing asset operation grammar.

## Changed Files

| file | change |
|---|---|
| `tools/probe_gqm17_windows.gd` | Uses `HexVector.directions()` for Adjacency proof keys; logs Markov SpinBox ranges; captures a Markov `8.0` proof state. |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | Narrows the Adjacency initial layout to 5 cards and gives `AdjacencyRuleSetName` an expandable minimum width. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/GQM-17_CRITERIA_WINDOW_DOD/` | Added task packet. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marks GQM-17 complete. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md` | Adds GQM-17 completion proof. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Treat Markov `1.0` as cosmetic if range is correct | Range verified and `8.0` captured | User correctly noted the `1.0` finding could mean max range, so proof now checks the range directly. | none |
| Avoid product changes until probe defects are excluded | Product change limited to Adjacency name/size after corrected capture | The black toggles were fixed by probe data, but name truncation remained visible. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Capture a criteria-window proof set | pass | `.godot_user/visual-verification/GQM-17/*.png` |
| Markov weights reflect `0.0..8.0` | pass | Probe log: 15 SpinBoxes with `min=0.0 max=8.0 step=0.5`; `markov_window_weight_8_probe.png` shows `8.0`. |
| Adjacency directions render correctly | pass | Probe key log: `["1,0,0", "0,0,-1"] / ["0,1,0"]`; capture shows black reference toggles and component labels. |
| Adjacency rule-set name is not truncated | pass | `adjacency_window_consolidated.png` shows the full placeholder in a wide field. |
| Item Pool morph is stable | pass | Limited/weighted captures show correct row labels; probe chip log remains `pool: inline` before and after. |

## Experiential DoD

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Criteria dialogs open with the primary controls visible: asset operations, editable fields, pattern previews, and numeric controls. |
| What user can do | pass | The user can edit Markov weights up to `8.0`, edit Adjacency rule metadata/pattern probabilities, and switch Item Pool limited/weighted rows. |
| Graph chain implication | pass | GQM-17 is criteria-window presentation; generation/runtime chain was already covered by GQM-11/GQM-16 and remains green in `./tools/test.sh`. |
| Label-heavy but metrics pass | no | The fixes expose actionable controls rather than adding explanatory labels. |

## Visual Proof

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tools/probe_gqm17_windows.gd`
- Result: pass, exit 0
- Captures:
  - `.godot_user/visual-verification/GQM-17/markov_window_consolidated.png`
  - `.godot_user/visual-verification/GQM-17/markov_window_weight_8_probe.png`
  - `.godot_user/visual-verification/GQM-17/adjacency_window_consolidated.png`
  - `.godot_user/visual-verification/GQM-17/item_pool_limited_rows.png`
  - `.godot_user/visual-verification/GQM-17/item_pool_weighted_after_switch.png`

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260703-162138-52536/workspace_layout_metrics.md` |
| P0 failures | 0 | report shows `total_p0_failures: 0` |
| P1 issues | 0 | report shows `total_p1_issues: 0` |
| UI metric applicability | UI task | GQM-17 changes criteria-window UI. |

## Repair-now Review

No repair-now issue remains. The initial false Adjacency finding was repaired in the probe; the confirmed Adjacency name/size discomfort was repaired in product UI.

## Test Review

- Command: `git diff --check`
- Result: pass
- Command: `/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tools/probe_gqm17_windows.gd`
- Result: pass, exit 0
- Command: `./tools/test.sh`
- Result: pass, exit 0, run id `20260703-162138-52536`
- Notes: macOS CA certificate warnings appeared as known non-fatal Godot output.
