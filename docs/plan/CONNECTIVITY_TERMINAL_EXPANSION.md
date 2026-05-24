# CONNECTIVITY_TERMINAL_EXPANSION.md

## 目的

`restore_connectivity` の代替アルゴリズム。
terminal からの最短 step 数（Dijkstra-like distance）が最大となる未到達 floor への経路を
優先する terminal expansion 方式。DSU 不要、`dist` ベースの到達性管理。
(`docs/plan/CONNECTIVITY_RESTORE_OPTIMIZATION.md` の続編)

## 対象コード

- `addons/hex_map_kit/core/hex_map_generator.gd:580` — `restore_connectivity_expand`
- `addons/hex_map_kit/core/hex_map_generator.gd:654` — `_bfs_to_unreachable`
- `addons/hex_map_kit/core/hex_map_generator.gd:715` — `_expand_dist_from_path`
- `addons/hex_map_kit/core/hex_map_generator.gd:755` — `_rebuild_path_inline`

## アルゴリズム（実装準拠）

### データ構造

```
dist[key]  : int            — cell の terminal(s) からの最短 step 数（floor 通過のみ）
wall_set   : Dict[key,cell] — 全 wall（反復に伴い削除）
cells_set  : Dict[key,cell] — 全 cell（探索範囲の上限）
```

`dist` が到達性のすべてを担う。DSU や component 管理は不要。

### フロー

```
restore_connectivity_expand(data, terminals=[]):

  wall_set = data.wall_set()
  cells_set = data.cell_set()

  if terminals が空 → terminals = [floor_cells[0]]

  # === Phase 1: 初期 terminal BFS（floor のみ） ===
  dist = {}
  for each terminal:
      dist[terminal.key] = 0
  BFS from dist keys through floors only.
  壁は通過しない。到達可能な全 floor cell の dist を計算。

  # === Phase 2: path-based iterative expansion ===
  while true:
      unreachable = floor_cells \ dist.keys     # 未到達 floor
      if unreachable が空: break

      # 到達済み領域から未到達 floor への最短経路を探索
      path = _bfs_to_unreachable(dist, unreachable, cells_set, wall_set, cyclic_size)
      if path が空: break

      # 経路上の壁だけを削除
      for cell in path:
          if cell in wall_set:
              wall_set.erase(cell.key)
              removed_walls.append(cell)

      # 新規到達 cell を terminal distance で埋める
      _expand_dist_from_path(dist, path, cells_set, wall_set, cyclic_size)

  data.set_walls(walls_from_set(wall_set))
  return removed_walls
```

### _bfs_to_unreachable — 経路探索

```
dist に含まれる全 cell を BFS start とする（到達済み領域全体）。
goal_set = unreachable cells の集合。
level-based BFS（cells 全体、壁含む）。

ある level 内に goal が 1 つでも見つかれば、同 level の全 goal を評価し、
terminal distance が最大のものを選ぶ（tiebreak）。
→ 複数の未到達成分が同距離にあれば、terminal から最も遠い成分に接続する。
```

`terminal distance`: goal cell 自身は未到達なので dist を持たない。代わりに **goal の隣接 cell の dist の最大値** を評価値とする。

```
for each goal at current level:
    neighbor_score = max{ dist[neighbor.key] | neighbor is reachable }
best = argmax neighbor_score
```

### _expand_dist_from_path — 到達領域の拡張

経路上の各 cell について:
- 既に dist あり → skip
- wall（削除済み）または floor → 隣接する到達済み cell の dist から min_d+1 を割り当て
- 新規到達 cell を seed に局所 BFS（floor のみ通過、wall 不通過）。dist を埋める

### 計算量

| Phase | 操作 | 計算量 |
|-------|------|--------|
| 1. 初期 BFS | floor cell 各 1 回訪問 | Θ(N) |
| 2. 反復: unreachable 列挙 | data.floor_cells() 全走査 | Θ(N) per iter |
| 2. 反復: _bfs_to_unreachable | cells 全体 BFS（level-based） | Θ(N) per iter |
| 2. 反復: 壁削除 | path 上の壁のみ | O(L) |
| 2. 反復: _expand_dist_from_path | 新規到達 cell のみ局所 BFS | amortized Θ(1) per cell |
| **合計** | C 反復 | **Θ(C × N)** |

C = 未到達成分数。実装上は C-1 反復で収束。

### 現行との比較

| | restore_connectivity (DSU+tiebreak) | restore_connectivity_expand |
|---|---|---|
| 計算量 | Θ(C × N) | Θ(C × N) |
| 反復 | C-1 回 | C-1 回 |
| 反復内 BFS | cell 全体 Θ(N)（`shortest_path_with_tiebreak`） | cell 全体 Θ(N)（`_bfs_to_unreachable`） |
| starts 構築 | cell 全走査 Θ(N) | 不要（dist keys から直接） |
| DSU | 必要 | **不要** |
| component 管理 | DSU.find/union | **不要**（dist が一元的に到達性を管理） |
| 壁削除順序 | 最近傍成分から逐次 | terminal から最遠の未到達 floor へ |
| tiebreak | 同距離で最大成分 | 同距離で最大 terminal distance |
| 総壁削除数 | 最小に近い | 最小に近い（path 上の壁のみ削除） |

## 設計上の決定

### なぜ greedy bucket 方式を捨てたか

初期設計の greedy bucket 方式は path 検証なしに壁を連鎖削除し、
全壁が消滅するバグがあった。path-based に修正した結果、
計算量は Θ(C × N) に戻ったが、正しさが保証される。

### DSU が不要な理由

`dist` 辞書が到達性を一元的に管理する:
- dist に key あり → 到達済み floor
- dist に key なし → 未到達（wall または未接続 floor）

反復のたびに全 cell を走査して component を再計算する必要がない。

### terminal distance tiebreak の設計

goal cell 自身は未到達のため dist を持たない。代わりに goal の隣接 cell のうち
dist を持つもの（＝到達済み領域に接する cell）の最大 dist を評価する。
これにより「terminal から最も遠い地点へ接続する経路」が優先される。

`best_dist_score` の初期値は `-2`。goal の全隣接が未到達の場合 `neighbor_score = -1`
となり、`-1 > -2` で選択される（`-1` どうしの `false` 比較回避）。

## toric 対応

全 BFS（初期・`_bfs_to_unreachable`・`_expand_dist_from_path`）で
`HexGrid.neighbors(cell, cyclic_size)` を使用。wrapping 済み。

## 複数 terminal 対応

`terminals` 配列の全 cell を Phase 1 で dist=0 として投入。多始点 BFS。

## 残存ボトルネックと改善方針

### 残存ボトルネック

`_bfs_to_unreachable` が cells 全体 BFS（Θ(N)）を C-1 回実行する。
C が多い場合（wall_probability 中程度）、支配的。

### 改善方針（設計判断が必要）

| 方針 | 計算量変化 | 副作用 |
|------|-----------|--------|
| **boundary starts**: 全到達済み cell ではなく、wall 隣接 cell のみを BFS start にする | Θ(N) → 実効 Θ(perimeter) | 実装複雑度↑。perimeter 管理必要 |
| **bidirectional BFS**: 未到達側からも同時 BFS | 探索空間半減 | 実装複雑度↑ |
| **O(N) flood fill**: 最短経路保証を捨て、terminal から層状に wall を開ける | **Θ(N)**（単一パス） | 壁削除数が増加。連結形状が terminal 中心の木構造になる |

flood fill を選択する場合の仕様変更:
- 「連結に必要な壁のみ削除」から「terminal から flood fill で到達できる全 cell を開く」へ
- 1 反復で済むため Θ(N)。ただし壁削除数が現行の数倍になる可能性がある
- 地図の連結形状が terminal を根とする全域木になる
