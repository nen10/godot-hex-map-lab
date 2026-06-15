# DESIGN-11 Tab IA And Priority

Reference:

- `DESIGN-10_BACKBONE_WIREFRAMES/WIREFRAMES.md`
- `docs/policy/LAYOUT_SKETCH_POLICY.md`
- `docs/design/PRODUCT_DEFINITION.md`

## 1. Tab Bar Set, Order, And Rename

The tab bar is ordered left to right by work importance, not by implementation ownership.

| order | tab | group | rename / source | role |
|---:|---|---|---|---|
| 1 | Build | Primary | `Generate` -> `Build` | Graph build surface and generation entry |
| 2 | Paint | Primary | unchanged | Manual design and finish surface |
| 3 | Catalog | Support | unchanged | Map vocabulary: tile/object entries |
| 4 | Layers | Support | unchanged | Map structure: role stack |
| 5 | Resources | Support | unchanged | Map binding: asset shelf |
| 6 | Export | Utility | unchanged | Godot handoff endpoint |
| 7 | Settings | Utility | unchanged | Workspace preferences |

Not in the tab bar:

| parked surface | access | reason |
|---|---|---|
| QA | `[Diagnostics]` drawer | Observes; does not define the main creation path |
| Validate | `[Diagnostics]` drawer | Observes; does not define the main creation path |

## 2. Priority Classification

| group | tabs | role | tab bar position |
|---|---|---|---|
| Primary | Build, Paint | Creation work surfaces | Front, visually emphasized |
| Support: map semantics | Catalog, Layers, Resources | Vocabulary / structure / binding shelves that support Build and Paint | Middle |
| Utility | Export, Settings | Handoff and workspace preferences | End |
| Parked | QA, Validate | Observation and diagnostics only | Outside the tab bar |

Classification is not the same as workflow order. Export is Utility in the tab bar, but it remains the endpoint in the workflow strip.

## 3. Tab-To-Document Flow

The Level Document is the hub. Build and Paint both write to it; Catalog, Layers, and Resources support it; Export reads from it.

```text
        +-----------+        +------------------+        +-----------+
        | Catalog   | -----> |                  | <----- | Layers    |
        | vocabulary|        |  Level Document  |        | structure |
        +-----------+        |                  |        +-----------+
                             |                  |
        +-----------+ -----> |                  |
        | Resources |        +--------+---------+
        | binding   |                 ^
        +-----------+                 |
                                      | promote output
                                  +---+---+
                                  | Build |
                                  +---+---+
                                      |
                                      | edit/read
                                      v
                                  +---+---+
                                  | Paint |
                                  +---+---+
                                      |
                                      | handoff
                                      v
                                  +---+----+
                                  | Export |
                                  +--------+

QA / Validate: observe only through [Diagnostics] drawer.
```

Main workflow:

```text
Build -> Paint -> Export
```

Support workflow:

```text
Catalog / Layers / Resources -> Level Document -> Build / Paint
```

## 4. Global Top Strip

The global top strip is the workspace home. It is always visible above the tab bar and answers:

- Which map is active.
- Whether the active map has unsaved or missing setup.
- Where the user is in `Build -> Paint -> Export`.
- What the next global action is.
- Where diagnostics live.

Configured state:

```text
+--------------------------------------------------------------------------------+
| Map: Dungeon_01        Draft / Unsaved        Build > Paint > Export            |
| Current: Build                              [Paint] [Export] [Diagnostics]      |
+--------------------------------------------------------------------------------+
| [Build] [Paint]   [Catalog] [Layers] [Resources]   [Export] [Settings]         |
|  primary           support: map semantics          utility                      |
+--------------------------------------------------------------------------------+
```

Missing setup state:

```text
+--------------------------------------------------------------------------------+
| Map: Dungeon_01        Missing: Tile Catalog        Build > Paint > Export      |
|                                                [Choose Catalog] [Diagnostics]   |
+--------------------------------------------------------------------------------+
| [Build] [Paint]   [Catalog] [Layers] [Resources]   [Export] [Settings]         |
|  primary           support: map semantics          utility                      |
+--------------------------------------------------------------------------------+
```

Top strip contents:

| item | normal behavior | missing behavior |
|---|---|---|
| `Map: <name>` | Shows selected map | Shows selected map or choose state |
| state | Shows Draft / Unsaved / Saved | Replaced or paired with `Missing: <asset>` |
| workflow | Shows `Build > Paint > Export`, current step emphasized by position and `Current:` | Same workflow remains visible |
| CTA | Offers next workflow action, such as `[Paint]` or `[Export]` | Offers setup CTA, such as `[Choose Catalog]` |
| Diagnostics | Opens parked QA/Validate drawer | Same |

## 5. Global Strip / Per-Tab Context Strip Boundary

| strip | owner task | contents | does not contain |
|---|---|---|---|
| Global top strip | DESIGN-11 | Active map, save/setup state, `Build > Paint > Export`, missing setup CTA, `[Diagnostics]` | Tab-specific catalog/target/layer/brush details |
| Per-tab context strip | DESIGN-10 | Tab-local chips such as Catalog, Target role, Layer, Brush, selected asset context | Global `Map` state once the top strip is present |

Implementation note: DESIGN-10 sketches show per-tab context chips for the local surface. DESIGN-11 makes `Map` global so implementation should avoid showing the same map ownership twice.

## 6. Acceptance Self-Check

| requirement | result | evidence |
|---|---|---|
| Tab set/order/rename documented | PASS | Section 1 has 7 tabs and `Generate` -> `Build` |
| Priority classification documented | PASS | Section 2 covers Primary / Support / Utility / Parked |
| Tab dependency flow documented | PASS | Section 3 shows Level Document hub and Build -> Paint -> Export |
| Global top strip specified | PASS | Section 4 has configured and missing setup ASCII |
| Global/per-tab boundary documented | PASS | Section 5 separates global `Map` from local chips |
| QA/Validate parked | PASS | Sections 1, 2, 3, and 4 route them only through `[Diagnostics]` |
