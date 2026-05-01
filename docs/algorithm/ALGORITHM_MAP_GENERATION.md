#  ALGORITHM_MAP_GENERATION.md

## 目的

このドキュメントは、Core 実装の map 生成アルゴリズムを説明する。

## 対象コード

- `addons/hex_map_kit/core/hex_map_data.gd`
- `addons/hex_map_kit/core/hex_map_generator.gd`
- `addons/hex_map_kit/core/hex_grid.gd`
- `addons/hex_map_kit/core/hex_toric_coordinate.gd`
- `addons/hex_map_kit/core/hex_randomizer.gd`
- `addons/hex_map_kit/core/hex_map_debug.gd`

## データモデル

`HexMapData` は以下を持つ。

- `cells`: map 上に存在する Hex 座標の一覧
- `walls`: `cells` のうち壁として扱う Hex 座標の一覧
- `cyclic_size`: toric map の周期。`0` の場合は non-toric

floor は明示的に保持しない。`cells - walls` を floor として扱う。

## 生成フロー

### 1. cell 領域を作成する

non-toric の入口は `HexMapData.rectangle(width, height, false)` または `HexMapGenerator.generate_rectangle(..., toric=false)`。

作成される `cells` は axial 風に次の範囲で列挙する。

```text
q = 0 ... width - 1
r = 0 ... height - 1
cell = HexVector.apply_basis(q, 0, r)
```

六角形 map の入口は `HexMapData.hexagon(radius)` または `HexMapGenerator.generate_hexagon(...)`。

`HexGrid.l1_disc(radius)` により、中心 `HexVector.zero()` から `HexVector.l1_norm() <= radius` の cell を列挙する。半径 `0` は中心 1 cell、半径 `r` の cell 数は `1 + 3r(r + 1)`。

toric の入口は `HexMapData.toric_square(size)` または `HexMapGenerator.generate_toric_square(...)`。

toric は現時点では正方形のみを対象にする。`cyclic_size = size` として保存する。

### 2. ランダム壁を配置する

`HexMapGenerator.generate_random_walls(cells, wall_probability, seed, protected_floor)` が、各 cell に対して独立に乱数を引く。

```text
randf() < wall_probability なら壁
```

`protected_floor` に含まれる cell は壁にしない。

乱数は `RandomNumberGenerator.seed` により固定するため、同じ seed と同じ cell 順なら同じ壁集合になる。

### 3. 連結性を判定する

`HexMapGenerator.is_floor_connected(data)` は、floor cell 全体が 1 つの連結成分かどうかを判定する。

内部では `HexGrid.connected_area(start, floor_cells, cyclic_size)` による BFS を使う。

### 4. 連結性を回復する

`HexMapGenerator.restore_connectivity(data)` は、floor が複数成分に分かれている場合に壁を削って接続する。

処理は以下。

1. floor が空なら、先頭 cell を 1 つだけ floor にする。
2. floor の連結成分を列挙する。
3. 先頭成分から、他成分のいずれかへ BFS で最短経路を探す。
4. 経路上の wall を `walls` から取り除く。
5. 連結成分が 1 つになるまで繰り返す。

BFS の探索空間は `cells` 全体であり、floor だけではない。これは「壁を削れば通路にできる候補」を探索するため。

### 5. デバッグ表示

`HexMapDebug.render_ascii(data)` は、`HexMapData` を deterministic な文字列として表示する。

標準の表示文字は以下。

- floor: `.`
- wall: `#`
- missing cell: 半角スペース

`cells` の axial 範囲を `r` 行、`q` 列として走査する。`indent_rows` が `true` の場合、奇数 `r` 行の先頭に missing cell 文字を 1 つ追加し、hex 行のずれを簡易表示する。

`HexMapDebug.render_summary(data)` は、データ確認用に `cells`、`walls`、`floors`、`cyclic_size` の件数を 1 行で返す。

この表示は Core データの確認用であり、TileMapLayer 表示や最終的なゲーム内描画ではない。

## Toric と Non-Toric の差異

### neighbor の扱い

non-toric では `cyclic_size = 0`。`HexGrid.neighbors()` は単に 6 近傍を返す。map の外に出る neighbor は `cells` に含まれないため、連結探索では無視される。

toric では `cyclic_size > 0`。`HexGrid.neighbors()` は各 neighbor を `HexToricCoordinate.wrap_vector()` で正規化する。端を越えた座標は同じ map 内の反対側へ戻る。

### 領域形状

non-toric は長方形 `width x height` と半径指定の六角形を扱える。

toric は現時点では `size x size` の正方形のみを扱う。`HexMapData.rectangle(width, height, true)` は `width == height` を要求する。明示 API としては `HexMapData.toric_square(size)` と `HexMapGenerator.generate_toric_square(...)` を使う。

### 連結性回復

non-toric の回復経路は map 外へ出られない。

toric の回復経路は端を跨げる。したがって、non-toric なら遠回りになる配置でも、toric では境界越しの短い経路により少ない壁削除で接続できる場合がある。
