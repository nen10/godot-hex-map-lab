#  ALGORITHM_MAP_GENERATION.md

## 目的

このドキュメントは、Core 実装の map 生成アルゴリズムを説明する。

## 対象コード

- `addons/hex_map_kit/core/hex_map_data.gd`
- `addons/hex_map_kit/core/hex_map_generator.gd`
- `addons/hex_map_kit/core/hex_grid.gd`
- `addons/hex_map_kit/core/hex_toric_coordinate.gd`
- `addons/hex_map_kit/core/hex_toric_map_split_rule.gd`
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

toric の入口は `HexMapData.square(size, true)` または `HexMapGenerator.generate_toric_square(...)`。

toric は現時点では正方形のみを対象にする。`cyclic_size = size` として保存する。

### Toric 正方形の 9 分割

`HexToricMapSplitRule(map_unit_radius)` は、Unity 版 `HexToricMapSplitRule` の三角形 9 分割を Core データとして作る。

- `cyclic_size = map_unit_radius * 2 + 1`
- split 0-7 は `Geometry.Triangle(edgeLength, origin, flatLeft)` 相当の三角形
- split 8 は中心 cell 1 つ
- 9 個の split は `cyclic_size x cyclic_size` の toric square 全体を重複なく覆う

この分割は、正方形 toric map と六角形としての理解を対応づける処理、および外周から内側への対称生成アルゴリズムの前提になる。

分割に使える toric square の一辺サイズは `N = 2 * map_unit_radius + 1` で表される奇数に限る。Unity 版の constructor 自体は明示的な検証を持たないが、`MapUnitRadius` を整数として三角形の辺長、中心 cell、外周参照を決めるため、9 分割としては正の整数半径 `map_unit_radius >= 1`、つまり `N >= 3` の奇数が前提である。対称生成内の外周描画は `(MapUnitRadius - 1) % 3` による 3 パターンを扱うため、`map_unit_radius` が 3 の倍数である必要はない。

`symmetry_generation_entries()` は Unity 版 `HexToricMap.DrawThreadsOnToricMap()` の幾何的な描画順を可視化用に移植したものである。乱数による壁生成結果ではなく、どの領域が描画候補になるかだけを返す。

- `outer_mod`: `DrawAreaCenter()` に対応する。`(MapUnitRadius - 1) % 3` で形が変わる外周側の開始領域
- `outer_wave`: `DrawAreaFromCenter()` に対応する。split 0 / split 7 に位置する、外周側領域。
- `border_initial` / `border_edge`: `DrawBoarder()` に対応する、外周を越える参照位置を `ReferencePositions` によって canvas 内へ移した領域
- `inner_arc`: `DrawInnerArea()` に対応する、6 方向の arc で中心へ向かう共通領域
- `center`: `DrawInnerArea()` の最後にコード上で求める中心 cell。phase 2 では `DrawAreaFromCenter()` の結果をそのまま使うため、debug tag の split は 8 固定ではなく canvas 上の生成位置を示す
- `completion`: 上記の Unity source 順序後に未訪問の canvas cell が残った場合だけ、その cell を埋める completion pass。`symmetry_generation_tags()` は必ず `canvas_cells()` 全体を網羅する

phase 2 の `outer_mod` は split 0 / split 7 にそれぞれ 6 個、合計 12 個の raw 生成座標を持つ。`symmetry_phase2_outer_mod_groups()` は、phase 2 の開始形状に含まれる pair/triple の生成タイミングを可視化する診断用 helper である。この pair/triple は同一 toric cell を意味しない。raw 座標は `source` に保持し、canvas 上の座標は `vector` に wrap して保持する。

`symmetry_unity_reference_groups()` は、Unity 版の `ReferencePositions` 相当で canvas 内に戻される source を debug 表示用に bucket 化する helper である。これは外周を越えた描画 source がどの reference へ戻されるかを調べるための情報で、`symmetry_phase2_outer_mod_groups()` の pair/triple と同じ意味の group ではない。


### 対称 toric 正方形の壁生成

`HexMapGenerator.generate_symmetric_square(size, wall_probability, seed, connect_method, protected_floor, distribution_id, terminal_floor, connect_toric)` は Unity 版 `HexToricMap.DrawThreadsOnToricMap()` の描画順を Core の壁生成として使う。

- `size` は `2 * map_unit_radius + 1` の odd N のみ
- `distribution_id` は `HexRandomizer.prob_from_distribution()` の 2x2x2 テーブルを使う
- `protected_floor` と `terminal_floor` は生成中も floor として扱い、壁にしない
- 生成された壁は toric 座標で `size x size` の正方形 canvas に畳み、9 分割された split のいずれかに対応する

`(map_unit_radius - 1) % 3 == 2` の phase 2 相当でも、Unity 版と同じく `DrawAreaCenter()` の後に `DrawAreaFromCenter()` を実行し、その結果の draw node を border / inner の生成へ渡す。`map_unit_radius % 3 == 0` だけ外周境界補正へ置き換える分岐は持たない。

`DrawAreaFromCenter()` の波数は `floor(map_unit_radius / 3)` として扱う。これにより radius `1` / `2` でも同じ描画フローを使い、終了しない `while pen != origin` 型の分岐を持たない。

Unity source 順序だけでは phase 2 の radius `3` / `6` / `9` で未訪問 canvas cell が残るため、Godot 側では最後に canvas completion pass を実行する。completion は未訪問 cell だけを `wall_probability` で描画し、既に source 順序で訪問した cell は再生成しない。

### 2026-05-21: radius 3倍数の調査記録

`seed=888`、`wall_probability=1.0`、`protected_floor=[HexVector.zero()]` で radius `3` / `6` / `9` を headless 確認した。これらはすべて `(radius - 1) % 3 == 2` の phase 2 で、`symmetry_phase2_outer_mod_groups()` は 5 groups を返す。

`connect_method=CONNECT_NONE` の raw 生成では square と torus は同じ wall set になる。`connect_method=CONNECT_DENSE` / `CONNECT_SPARSE` では torus の方が cyclic 経路を使えるため、non-toric square / hex と floor corridor の削られ方が変わる。

原因候補は次の通り。

- `wall_probability=1.0` でも対称生成は distribution 参照を使うため、raw の時点で floor seed が多数残る。
- `Restore Connectivity` は既存 floor component を接続するために壁を削る。max wall 条件ではこの削除結果が長い通路として目立つ。
- `HexVector.zero()` は 9 split の幾何中心ではなく、protected floor の起点として通路の見た目に強く影響する。
- Hexagon shape は square 生成後に split 0 / 7 を除くため、phase2 の outer_mod / outer_wave が形状外へ落ち、square / torus と分布が変わる。
- `symmetry_generation_tags()` は全 cell 網羅を仕様とする。phase2 で残っていた未タグ cell は completion pass の対象として記録する。

### 2. ランダム壁を配置する

`HexMapGenerator.generate_random_walls(cells, wall_probability, seed, protected_floor)` が、各 cell に対して独立に乱数を引く。

```text
randf() < wall_probability なら壁
```

`protected_floor` に含まれる cell は壁にしない。

乱数は `RandomNumberGenerator.seed` により固定するため、同じ seed と同じ cell 順なら同じ壁集合になる。

### 2.1 割り込み可能な壁生成

progressbar / cancel 用に、Core は interruptible 版の壁生成 API を持つ。

- `generate_random_walls_interruptible(...) -> Dictionary`
- `generate_symmetric_toric_walls_interruptible(...) -> Dictionary`

戻り値:

- `walls: Array[HexVector]`
- `cancelled: bool`
- `progress: float`
- `steps: int`
- `total_steps: int`

`interrupt_options` には以下を渡せる。

- `chunk_size: int`
- `progress_callback: Callable`
- `cancel_callback: Callable`

callback には `phase` / `steps` / `total_steps` / `progress` を持つ `Dictionary` を渡す。`cancel_callback` が `true` を返した場合、その時点までの wall set を返して中断する。

`generate_rectangle()`、`generate_toric_square()`、`generate_hexagon()`、`generate_symmetric_square()`、`generate_symmetric_hexagon()` は末尾の `interrupt_options` を受け取り、指定された場合だけ interruptible 版の壁生成に分岐する。cancel 時は connectivity restoration を実行せず、partial wall map を返す。

### 3. 連結性を判定する

`HexMapGenerator.is_floor_connected(data)` は、floor cell 全体が 1 つの連結成分かどうかを判定する。

内部では `HexGrid.connected_area(start, floor_cells, cyclic_size)` による BFS を使う。

`HexGrid.shortest_path(start, goals, enterable_points, cyclic_size)` は、`enterable_points` 上だけを通る最短経路を BFS で返す。戻り値は start と到達した goal を含む座標列。到達不能な場合は空配列を返す。

### 4. 連結性を回復する

Core の通常方式は `CONNECT_DENSE` / `CONNECT_SPARSE` / `CONNECT_NONE` の 3 つに絞る。

- `CONNECT_DENSE`: `HexMapGenerator.restore_connectivity_dense()` を使う。壁削除数を抑えつつ全 floor 成分を接続する標準方式。
- `CONNECT_SPARSE`: `HexMapGenerator.restore_connectivity_sparse()` を使う。Dense より壁削除が増えやすいが、通路感を強めたい場合の代替方式。
- `CONNECT_NONE`: 連結性回復を実行しない raw 生成。

`HexMapGenerator.restore_connectivity()` は scripting 互換用に残し、Dense 方式へ委譲する。`terminal_floor` は connect method ではなく、symmetric 生成時に `restore_terminal_connectivity()` で事前接続する。

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

toric は現時点では `size x size` の正方形のみを扱う。`HexMapData.rectangle(width, height, true)` は `width == height` を要求する。明示 API としては `HexMapData.square(size, true)` と `HexMapGenerator.generate_toric_square(...)` を使う。

### 連結性回復

non-toric の回復経路は map 外へ出られない。

toric の回復経路は端を跨げる。したがって、non-toric なら遠回りになる配置でも、toric では境界越しの短い経路により少ない壁削除で接続できる場合がある。
