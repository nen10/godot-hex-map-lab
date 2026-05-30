# GENERATIVE_REFERENCE_ITEMKEY_IMPLEMENTATION_PLAN_2026-05-31.md

## 参照方針

- 方針: `docs/plan/GENERATIVE_REFERENCE_ITEMKEY_POLICY_2026-05-31.md`
- 採用案: Core APIの動的参照オプションとして実装する。

## 対象ファイル

- `addons/hex_map_kit/core/hex_map_generator.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## 入出力インターフェース

入力:

- `cells: Array[HexVector]`
- `item_name: String`
- `reference_cells: Array[HexVector]`
- `probability_rules: Dictionary`
- `seed: int`
- `blocked_cells: Array[HexVector]`
- `cyclic_size: int`
- `neighbor_radius: int`
- `include_generated_reference: bool`
- Editor snapshot key: `overlay_generated_reference_enabled`

出力:

- `Dictionary` result
  - `data: HexOverlayData`
  - `cancelled: bool`
  - `steps: int`
  - `total_steps: int`
- `HexOverlayData.items[item_name]`
- progress / cancel callback status

## Core API計画

### 追加する入力

`HexMapGenerator.generate_toric_adjacency_items_interruptible()` に動的参照optionを追加する。

候補signature:

```gdscript
static func generate_toric_adjacency_items_interruptible(
    cells: Array,
    item_name: String,
    reference_cells: Array,
    probability_rules: Dictionary = {},
    seed: int = 0,
    blocked_cells: Array = [],
    cyclic_size: int = 0,
    neighbor_radius: int = 1,
    interrupt_options: Dictionary = {},
    include_generated_reference: bool = false
) -> Dictionary:
```

破壊的変更を許容する場合は、後続引数をdictionaryへ移す。

```gdscript
static func generate_toric_adjacency_items_interruptible(
    cells: Array,
    item_name: String,
    options: Dictionary = {}
) -> Dictionary:
```

代表案では既存呼び出し差分を小さくするため、末尾引数追加で進める。

### Core処理

1. `reference_cells` を `_normalize_generation_points(reference_cells, cyclic_size)` で正規化する。
2. `reference_set` を `HexMapData.make_set(normalized_reference_cells)` で作る。
3. candidate走査前に `include_generated_reference` をbool化する。
4. 各candidateで従来通り `_adjacency_reference_stats()` を呼ぶ。
5. placement probabilityによりitemを置いた場合:
   - `data.add_item_cell(item_name, cell)` を呼ぶ。
   - `include_generated_reference` がtrueなら、同じcellを `reference_set[cell.key()] = cell` として追加する。
6. cyclic mapではcandidate自体が `_item_generation_candidates(cells, blocked_cells, cyclic_size)` でwrap済みなので、追加keyもwrap済みになる。

### 期待する出力

- 戻り値の `data` は従来通り `HexOverlayData`。
- `steps` / `total_steps` / `cancelled` は従来通り。
- 追加したreference_setは内部状態であり、resourceへ保存しない。

## Editor Dock計画

### UI

`_build_overlay_adjacency_controls()` の Reference Query Rowセクションにcheckboxを追加する。

候補名:

- Label: `Generated Item Reference`
- Tooltip: `Use generated target item cells as additional adjacency reference while this generation runs.`

内部変数:

```gdscript
var _overlay_generated_reference_check: CheckButton
```

### Snapshot

`_create_generation_snapshot()` に以下を追加する。

```gdscript
"overlay_generated_reference_enabled": _overlay_generated_reference_enabled(),
```

helper:

```gdscript
func _overlay_generated_reference_enabled() -> bool:
    return _overlay_adjacency_enabled() \
        and _overlay_generated_reference_check != null \
        and _overlay_generated_reference_check.button_pressed
```

generation threadではUI nodeを読まず、snapshot値だけを使う。

### Core呼び出し

`_generate_overlay_data_from_snapshot()` の adjacency branchで、Core APIへ `overlay_generated_reference_enabled` を渡す。

```gdscript
data = HexMapGenerator.generate_toric_adjacency_items_interruptible(
    candidates,
    item_name,
    snapshot.get("overlay_reference_cells", []),
    snapshot.get("overlay_adjacency_rules", {}),
    seed,
    [],
    int(snapshot.get("overlay_cyclic_size", 0)),
    int(snapshot.get("overlay_neighbor_radius", 1)),
    interrupt_options,
    bool(snapshot.get("overlay_generated_reference_enabled", false))
)["data"]
```

## Resource schema

保存resourceのschemaは変更しない。

- `HexOverlayData.items` には生成結果だけを保存する。
- generated reference setは生成中の確率計算用stateであり、`.tres` へ保存しない。
- Generate Historyは従来通り生成差分 `HexOverlayResource` を保存する。

## テスト計画

### `tests/test_hex_map_generation.gd`

追加テスト候補:

- `_test_toric_adjacency_items_can_reference_generated_item()`
  - candidateを直線3cellにする。
  - rulesは `default=1.0` ではなく、neighbor countによって配置が変わる値にする。
  - seedの影響を避けるため、最初のcellだけ配置される条件を作るか、probability 1.0 / 0.0のrulesを使う。
  - generated reference Offでは2cell目が条件を満たさず、Onでは満たすことを検証する。
- `_test_toric_adjacency_generated_reference_wraps()`
  - cyclic_size=3でedge cellに生成されたitemが反対側candidateのneighborとして扱われることを検証する。

### `tests/test_editor_plugin.gd`

追加テスト候補:

- `_test_generation_dock_adjacency_generated_reference_snapshot()`
  - Overlay + symmetric + Adjacency Rulesを有効化する。
  - checkbox On/Offで `_create_generation_snapshot()` の `overlay_generated_reference_enabled` が変わる。
- `_test_generation_dock_adjacency_generated_reference_changes_result()`
  - 小さなcandidate fixtureでGenerateを実行し、On時だけ生成済みitemが以後のreferenceになることを確認する。

### `docs/TEST.md`

`test_hex_map_generation.gd` と `test_editor_plugin.gd` の概要に以下を追加する。

- Adjacency Referenceで生成済みtarget itemを動的referenceへ加えること。
- checkbox Offで静的Reference Query Rowのみを使うこと。

## 実装手順

1. Core APIに `include_generated_reference` を追加する。
2. Core testを追加し、Off/Onの差分を固定する。
3. Editor Dockにcheckboxとsnapshot keyを追加する。
4. Editor Dock testでsnapshotと生成結果を固定する。
5. `docs/TEST.md` を更新する。
6. `./tools/test.sh` を実行する。

## 完了判定

- 動的referenceのCore testが通る。
- Editor Dockのcheckbox状態がsnapshotからCore APIへ渡る。
- 既存Adjacency Reference生成テストがcheckbox Offで維持される。
- 生成cancel時のcurrent overlay非反映が維持される。
