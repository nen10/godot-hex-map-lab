# DESIGN-10 Backbone Wireframes

Reference: `docs/policy/LAYOUT_SKETCH_POLICY.md`

Legend:

- `[Action]` = button or direct command.
- `( Key: value )` = context chip for map semantics.
- The largest area in each sketch is the dominant work surface.
- `# note` = resource escape hatch or state note outside the main surface.

## Build

Normal: 主役=graph canvas + output preview / primary action=`[Generate]` / resource 退避先=`Resources` tab

```text
+----------------------------------------------------------------------------------+
| ( Map: Overworld ) ( Catalog: Dungeon Kit ) ( Target: generated terrain )         |
|                                                                       [Generate] |
+----------------------------------------------------------------------------------+
| GRAPH CANVAS                                             | OUTPUT PREVIEW          |
|                                                          |                         |
|  [Shape] --> [Wall] --> [Connectivity] --> [Region Filter]   hex mini-map          |
|     |           |            |                  |          |   terrain + selection |
|  size/seed   edges       connected floor     spawn ring    |                         |
|                                                          |                         |
|  + add node rail: Shape | Wall | Filter | Item | Promote   |                         |
+----------------------------------------------------------------------------------+
| Selected node: Region Filter | Inputs: terrain | Outputs: selection | params        |
| [Promote output to Layer] [Use as Filter Input]                                    |
+----------------------------------------------------------------------------------+
| Secondary controls: N=1 | seed | shape randomize                                    |
+----------------------------------------------------------------------------------+
```

Empty: 主役=start build CTA / primary action=`[New Pipeline]` / resource 退避先=`Resources` tab

```text
+----------------------------------------------------------------------------------+
| ( Map: choose ) ( Catalog: choose ) ( Target: generated terrain )                  |
+----------------------------------------------------------------------------------+
|                                                                                  |
|                                Start a build                                     |
|                                                                                  |
|              [New Pipeline]   [Simple: choose Generation Profile]                |
|                         [Open sample as tutorial]                                |
|                                                                                  |
|        # Simple opens a preset graph; it is not a separate mode.                 |
+----------------------------------------------------------------------------------+
```

### Build §6 self-check

- [x] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [x] 主役が dominant で、resource 詳細より前に来る
- [x] primary action が1つ明確
- [x] empty state が CTA（ラベル列でない）
- [x] label budget 準拠（内部語彙なし）
- [x] normal + empty の2状態を描いた
- [x] （選択型タブ）inspector が選択 node を表示
- [x] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない

## Paint

Normal: 主役=brush palette + edit status with Godot 2D viewport / primary action=brush and shape selection / resource 退避先=`Layers` and `Catalog`

```text
+----------------------------------------------------------------------------------+
| ( Map: Overworld ) ( Layer: document terrain ) ( Brush: grass_01 )                |
+----------------------------------------------------------------------------------+
| BRUSH PALETTE                         | GODOT MAIN 2D VIEWPORT                    |
|                                       |                                           |
| [grass_01] [wall_01] [water_01]       |   q,r grid with painted preview           |
| [torch]    [door]    [spawn]          |   active brush cursor on hovered cell      |
|                                       |                                           |
| Shape: [single] [line] [disc] [flood] |                                           |
|                                       |                                           |
| Cell: q=12 r=-4                       | Last edit: painted 8 cells on terrain      |
+----------------------------------------------------------------------------------+
```

Empty: 主役=paint setup CTA / primary action=`[Create Level Document]` / resource 退避先=`Resources`

```text
+----------------------------------------------------------------------------------+
| ( Map: choose ) ( Layer: choose ) ( Brush: choose )                               |
+----------------------------------------------------------------------------------+
|                                                                                  |
|                               No paintable map                                   |
|                                                                                  |
|                   [Create Level Document]   [Choose Level Document]              |
|                                                                                  |
|             # Layer details move to Layers; catalog choices move to Catalog.      |
+----------------------------------------------------------------------------------+
```

### Paint §6 self-check

- [x] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [x] 主役が dominant で、resource 詳細より前に来る
- [x] primary action が1つ明確
- [x] empty state が CTA（ラベル列でない）
- [x] label budget 準拠（内部語彙なし）
- [x] normal + empty の2状態を描いた
- [x] （選択型タブ）Paint は独立 inspector なし。選択 brush / cell / last edit を status として表示
- [x] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない

## Export

Normal: 主役=handoff purpose cards / primary action=`[Export .tres]` / resource 退避先=destination drawer/dialog

```text
+----------------------------------------------------------------------------------+
| ( Map: Overworld )                                                               |
+----------------------------------------------------------------------------------+
| HANDOFF CARDS                                                                    |
|                                                                                  |
| +------------------------------+ +------------------------------+                |
| | Runtime Map Resource (.tres) | | Runtime Scene (.tscn)        |                |
| | For loading HexTileMapLayer  | | Layer node tree in a scene   |                |
| | [Export .tres]               | | [Create Scene]               |                |
| +------------------------------+ +------------------------------+                |
|                                                                                  |
| +------------------------------+                                                |
| | Generation Graph (.tres)     |                                                |
| | For runtime Map Build API    |                                                |
| | [Export Graph]               |                                                |
| +------------------------------+                                                |
|                                                                                  |
| Secondary: [Debug Report] [JSON Snapshot] [Package (disabled; tooltip)]          |
+----------------------------------------------------------------------------------+
```

Empty: 主役=handoff setup CTA / primary action=`[Build or select a map]` / resource 退避先=`Resources`

```text
+----------------------------------------------------------------------------------+
| ( Map: choose )                                                                  |
+----------------------------------------------------------------------------------+
|                                                                                  |
|                            Nothing to hand off yet                               |
|                                                                                  |
|                              [Build or select a map]                             |
|                                                                                  |
|                    # Destination path opens in a drawer or dialog.               |
+----------------------------------------------------------------------------------+
```

### Export §6 self-check

- [x] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [x] 主役が dominant で、resource 詳細より前に来る
- [x] primary action が1つ明確
- [x] empty state が CTA（ラベル列でない）
- [x] label budget 準拠（内部語彙なし）
- [x] normal + empty の2状態を描いた
- [x] （選択型タブ）Export は card choice が主で、独立 inspector は該当なし
- [x] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない

## Catalog

Normal: 主役=tile/object visual board / primary action=`[Add Entry]` / resource 退避先=`Resources` tab

```text
+----------------------------------------------------------------------------------+
| ( Catalog: Dungeon Kit )                                             [Add Entry] |
+----------------------------------------------------------------------------------+
| VISUAL ASSET BOARD                                      | SELECTED ENTRY          |
|                                                         |                         |
| +-----------+ +-----------+ +-----------+ +-----------+ | preview                 |
| | grass     | | wall      | | water     | | torch     | | name: wall             |
| | [tile]    | | [tile]    | | [tile]    | | [object]  | | tags: terrain, border  |
| +-----------+ +-----------+ +-----------+ +-----------+ | badge: ready            |
|                                                         |                         |
| +-----------+ +-----------+ +-----------+ +-----------+ | [Use in Paint]          |
| | door      | | spawn     | | bridge    | | stairs    | | [Edit Tags]            |
| | [object]  | | [object]  | | [tile]    | | [object]  | |                         |
| +-----------+ +-----------+ +-----------+ +-----------+ |                         |
+----------------------------------------------------------------------------------+
| # Source details stay in tooltip; catalog selection moves to Resources.          |
+----------------------------------------------------------------------------------+
```

Empty: 主役=catalog setup CTA / primary action=`[Create Catalog]` / resource 退避先=`Resources` tab

```text
+----------------------------------------------------------------------------------+
| ( Catalog: choose )                                                              |
+----------------------------------------------------------------------------------+
|                                                                                  |
|                                  No catalog                                      |
|                                                                                  |
|                     [Create Catalog]   [Choose Catalog]   [Open sample]          |
|                                                                                  |
+----------------------------------------------------------------------------------+
```

### Catalog §6 self-check

- [x] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [x] 主役が dominant で、resource 詳細より前に来る
- [x] primary action が1つ明確
- [x] empty state が CTA（ラベル列でない）
- [x] label budget 準拠（内部語彙なし）
- [x] normal + empty の2状態を描いた
- [x] （選択型タブ）inspector が選択 entry を表示
- [x] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない

## Layers

Normal: 主役=role stack visual tree / primary action=`[Add Role]` / resource 退避先=`Resources` tab

```text
+----------------------------------------------------------------------------------+
| ( Map: Overworld ) ( Layer Stack: Main Stack )                       [Add Role]  |
+----------------------------------------------------------------------------------+
| ROLE STACK VISUAL TREE                                  | SELECTED ROLE           |
|                                                         |                         |
| terrain  [visible] [unlocked] [source: document] [z:0]  | role: terrain           |
|   overlay_spawn [visible] [locked] [source: generated]  | source: document        |
|   overlay_items [visible] [unlocked] [source: target]   | z-index: 0              |
| object   [visible] [unlocked] [source: document] [z:20] | visible: on             |
| debug    [hidden]  [locked]   [source: readonly] [z:90] | lock: off               |
|                                                         | [Make Active]           |
| Drag handles reorder rows                               | [Duplicate Role]        |
+----------------------------------------------------------------------------------+
```

Empty: 主役=layer stack setup CTA / primary action=`[Create Layer Stack]` / resource 退避先=`Resources` tab

```text
+----------------------------------------------------------------------------------+
| ( Map: choose ) ( Layer Stack: choose )                                          |
+----------------------------------------------------------------------------------+
|                                                                                  |
|                                No layer stack                                    |
|                                                                                  |
|                         [Create Layer Stack]   [Choose Layer Stack]              |
|                                                                                  |
+----------------------------------------------------------------------------------+
```

### Layers §6 self-check

- [x] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [x] 主役が dominant で、resource 詳細より前に来る
- [x] primary action が1つ明確
- [x] empty state が CTA（ラベル列でない）
- [x] label budget 準拠（内部語彙なし）
- [x] normal + empty の2状態を描いた
- [x] （選択型タブ）inspector が選択 role を表示
- [x] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない

## Resources

Normal: 主役=asset shelf / primary action=`[Create Missing Resources]` / resource 退避先=該当なし（このタブが退避先）

```text
+----------------------------------------------------------------------------------+
| ( Selected HexTileMap: OverworldLayer )                                           |
|                                      [Create Missing Resources] [Save All]        |
+----------------------------------------------------------------------------------+
| ASSET SHELF                                                                      |
|                                                                                  |
| Unique to this map                                                               |
| +--------------------+ +--------------------+ +--------------------+             |
| | Level Document     | | Layer Stack        | | Build Graph        |             |
| | ready              | | ready              | | needs save         |             |
| +--------------------+ +--------------------+ +--------------------+             |
|                                                                                  |
| Shared project assets                                                            |
| +--------------------+ +--------------------+                                    |
| | Dungeon Catalog    | | Brush Set          |                                    |
| | ready              | | ready              |                                    |
| +--------------------+ +--------------------+                                    |
|                                                                                  |
| Optional                                                                         |
| +--------------------+ +--------------------+                                    |
| | Export Presets     | | Tutorial Samples   |                                    |
| | not required       | | available          |                                    |
| +--------------------+ +--------------------+                                    |
+----------------------------------------------------------------------------------+
```

Empty: 主役=map/resource setup CTA / primary action=`[Select a HexTileMap node]` / resource 退避先=該当なし

```text
+----------------------------------------------------------------------------------+
| ( Selected HexTileMap: choose )                                                  |
+----------------------------------------------------------------------------------+
|                                                                                  |
|                            No HexTileMap selected                                |
|                                                                                  |
|                             [Select a HexTileMap node]                           |
|                                                                                  |
|                                 Start a map                                      |
|                   [Create Level Document]   [Choose Tile Catalog]                |
|                                                                                  |
+----------------------------------------------------------------------------------+
```

### Resources §6 self-check

- [x] 必須リージョン（context strip / work surface / primary action / empty state）が揃う
- [x] 主役が dominant で、resource 詳細より前に来る
- [x] primary action が1つ明確
- [x] empty state が CTA（ラベル列でない）
- [x] label budget 準拠（内部語彙なし）
- [x] normal + empty の2状態を描いた
- [x] （選択型タブ）Resources は shelf card が主で、独立 inspector は該当なし
- [x] `WORKSPACE_UI_CONTRACT.md` の禁止事項に触れない
