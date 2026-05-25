# Multi Layer Symmetric Toric Items 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Markov Mesh かつ Adjacency Reference Off の Overlay item generation API を実装済みとして扱う。

## 入出力

入力:

- `radius: int`
- `item_name: String`
- `target_cells: Array[HexVector]`
  - Overlay item generation の生成対象 cell
- `wall_probability: float`
  - 既存 Markov Mesh の non-reference fallback probability と同じ扱い
- `seed: int`
- `distribution_id: int`
- `blocked_cells: Array[HexVector]`
  - target から除外する cell
- `custom_distribution`
- interrupt options
  - `chunk_size`
  - `progress_callback`
  - `cancel_callback`

出力:

- `HexOverlayData`
  - `cells`: toric wrap 後の target cells minus blocked cells
  - `item_name` に対応する generated item cells
- interruptible API の result `Dictionary`
  - `data`
  - `cancelled`
  - `progress`
  - `steps`
  - `total_steps`

## 実装状況

- [x] `generate_symmetric_toric_items()` を追加
- [x] `generate_symmetric_toric_items_interruptible()` を追加
- [x] 既存の `generate_symmetric_toric_walls_interruptible()` を利用し、target 外 cell を protected 扱いにして item 生成対象を制限する
- [x] `blocked_cells` を target から除外する
- [x] `cyclic_size = radius * 2 + 1` として target / blocked cell を toric wrap する
- [x] item name はユーザー定義文字列として扱い、Primary の `Wall` などと同名でも制限しない
- [x] seed 固定と progress / cancel に対応する

## テスト

- `tests/test_hex_map_generation.gd`
  - probability 1.0 で unblocked target cells に item が生成されること
  - blocked target cell には item が生成されないこと
  - 同じ seed で同じ item cells が生成されること
  - interruptible API が cancel 状態と `HexOverlayData` を返すこと
