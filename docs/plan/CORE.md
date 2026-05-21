# Core API 実装計画

## 目的

Editor Dock の progressbar / cancel に接続できるよう、Core の壁生成 API に割り込み可能な呼び出しを追加する。
既存の shape 生成 API は戻り値 `HexMapData` を維持しつつ、任意の `interrupt_options` を受け取った場合だけ progress / cancel 分岐を実行する。

## 追加 API

### interrupt options

入力:

- `chunk_size: int`
  random wall generation の progress callback 間隔。未指定時は `1`。
- `progress_callback: Callable`
  `Dictionary` を 1 引数で受け取る。
- `cancel_callback: Callable`
  `Dictionary` を 1 引数で受け取り、`true` を返すと生成を中断する。

callback payload:

- `phase: String`
- `steps: int`
- `total_steps: int`
- `progress: float`

生成後に `interrupt_options` へ記録する値:

- `cancelled: bool`
- `phase: String`
- `steps: int`
- `total_steps: int`
- `progress: float`
- `data: HexMapData`
  shape API から返した map data。

### 壁生成 API

- `generate_random_walls_interruptible(cells, wall_probability, seed, protected_floor, interrupt_options) -> Dictionary`
- `generate_symmetric_toric_walls_interruptible(radius, wall_probability, seed, distribution_id, protected_floor, custom_distribution, interrupt_options) -> Dictionary`

出力:

- `walls: Array[HexVector]`
- `cancelled: bool`
- `progress: float`
- `steps: int`
- `total_steps: int`

既存 API:

- `generate_random_walls(...) -> Array`
- `generate_symmetric_toric_walls(...) -> Array`

既存 API は interruptible 版を内部利用するが、戻り値は従来通り `Array` のままにする。

### shape API の interrupt option

以下の末尾に `interrupt_options: Dictionary = {}` を追加する。

- `generate_rectangle(...)`
- `generate_toric_square(...)`
- `generate_hexagon(...)`
- `generate_symmetric_square(...)`
- `generate_symmetric_hexagon(...)`

完了時:

- 通常通り `HexMapData` を返す。
- `ensure_connected` / `terminal_floor` は壁生成完了後に実行する。
- `interrupt_options["cancelled"] = false`
- `interrupt_options["progress"] = 1.0`

cancel 時:

- その時点までの `walls` を `HexMapData` に反映して返す。
- connectivity restoration は実行しない。
- `interrupt_options["cancelled"] = true`
- `interrupt_options["data"]` に返却した `HexMapData` を入れる。

## 形状別テスト

`tests/test_hex_map_generation.gd` で検証する。

- `generate_random_walls_interruptible`
  - progress callback
  - cancel callback
  - partial walls
- `generate_rectangle`
- `generate_toric_square`
- `generate_hexagon`
- `generate_symmetric_square(connect_toric=false)`
- `generate_symmetric_square(connect_toric=true)`
- `generate_symmetric_hexagon`

各 shape で検証すること:

- interrupt options ありでも、cancel しなければ通常生成と同じ `cells` / `walls` / `cyclic_size` になる。
- cancel callback が `true` を返すと `cancelled=true` になり、partial wall map を返す。
- progress event は単調増加する。

## 完了条件

- `tools/test.sh` が通る。
- `docs/TEST.md` に追加テスト範囲を記録する。
