# CONNECTIVITY_RESTORE_OPTIMIZATION.md

## 目的

`restore_connectivity` (`hex_map_generator.gd:497`) の large radius での遅延を解消し、
「最短経路の壁候補の中で、削除後に最大の連結領域を生むもの」を選択する要件を実現する。

## 対象コード

- `addons/hex_map_kit/core/hex_map_generator.gd` — `restore_connectivity`, `connected_components`, `restore_terminal_connectivity`
- `addons/hex_map_kit/core/hex_grid.gd` — `connected_area`, `shortest_path_to_any`

## 現行アルゴリズムの問題

### 計算量

N = cell 総数 = (2R+1)², C = 連結成分数。

```
while iterations < max_iterations:
    components = connected_components(data)       # BFS(floor_cells):  Θ(N)
    path = shortest_path_to_any(... data.cells)     # BFS(all_cells):    Θ(N)
    remove walls on path
```

- 計算量: **O(N × C)**
- 毎回 floor 全体 BFS + cell 全体 BFS を再実行
- 壁削除の影響は局所的だが、無関係な領域も再スキャン

### 要件未達

`shortest_path_to_any` (`hex_grid.gd:140`) は最初の goal cell 到達で即座に BFS を打ち切る。
同距離に複数の goal（別成分）が存在しても、FIFO 先着順で 1 つだけ選択する。
「最大の連結領域を生む壁」の選択は実装されていない。

## 設計: Union-Find + BFS tiebreak

### データ構造

```
DSU:
  parent[key]   : str         # 各 floor cell の親 key（経路圧縮）
  comp_size[key]: int         # 成分サイズ（root でのみ有効）
  comp_rep[key] : HexVector   # 成分の代表 cell（root でのみ有効）
  root_count    : int         # 成分数

補助:
  wall_set: Dictionary        # 既存。key → HexVector
  cells: Array[HexVector]     # 既存。全 cell
```

### 全体フロー

```
restore_connectivity(data):

  # === Phase 1: 初期 scan（1 回のみ） ===
  wall_set = data.wall_set()
  floor_cells = data.floor_cells()
  dsu = init_dsu(floor_cells)              # BFS floor → 連結成分 → DSU に投入
  if dsu.root_count == 0:
      # floor 空
      ...
      return
  if dsu.root_count == 1:
      return []

  # === Phase 2: 反復接続 ===
  root0 = dsu.find(floor_cells[0])
  while dsu.root_count > 1:
      targets = [dsu.comp_rep[r] for r in dsu.roots() if r != root0]
      if targets.is_empty(): return removed_walls

      path = shortest_path_with_tiebreak(
          starts      = cells_of_root0,
          goals       = targets,
          enterable   = data.cells,
          cyclic_size = data.cyclic_size,
          dsu         = dsu
      )
      if path.is_empty(): return removed_walls

      # 壁削除 + DSU 統合
      for point in path:
          if point in wall_set:
              removed_walls.append(point)
              wall_set.erase(key)
          # 新しく floor になった cell を DSU に追加
          dsu.make_set(point)
          for neighbor in neighbors(point, cyclic_size):
              if neighbor in wall_set: continue    # 壁は無視
              if not neighbor in cells: continue   # map 外
              dsu.make_set(neighbor)              # lazy init
              dsu.union(point, neighbor)

      root0 = dsu.find(root0_rep)  # 統合後の成分 root

  return removed_walls
```

## サブアルゴリズム詳細

### 1. init_dsu — 初期 floor 成分の構築

```
init_dsu(floor_cells):
    dsu = DSU()
    visited = {}
    for cell in floor_cells:
        if cell.key in visited: continue
        # BFS で 1 成分を列挙
        component = connected_area(cell, floor_cells, cyclic_size)
        root = component[0].key
        dsu.make_set_with_size(root, component.size())
        for c in component:
            dsu.parent[c.key] = root
            visited[c.key] = true
    return dsu
```

計算量: **Θ(N)**（floor 全体 BFS 1 回）

### 2. shortest_path_with_tiebreak — 最大成分選好 BFS

現行の FIFO 先着から、**同一 BFS 距離の全 goal を評価し最大成分に tiebreak**。

```
shortest_path_with_tiebreak(starts, goals, enterable, cyclic_size, dsu):

    # 距離情報付き BFS 用キュー
    # エントリ: (cell, distance, parent_key)
    queue = deque()
    visited = {}
    parent = {}

    for start in starts:
        key = start.key
        visited[key] = true
        parent[key] = ""
        queue.push((start, 0))

    current_distance = -1
    best_goal = null
    best_size = -1
    goal_set = make_set(goals)

    while queue:
        current, dist = queue.popleft()

        # 距離が進んだ → 前の距離層に goal があれば返す
        if dist > current_distance:
            if best_goal:
                return rebuild_path(best_goal, parent)
            current_distance = dist

        if goal_set.has(current.key):
            root_key = dsu.find(current.key)
            size = dsu.comp_size[root_key]
            if size > best_size:
                best_goal = current
                best_size = size
            continue   # goal からは展開しない（最短を保証）

        for neighbor in neighbors(current, cyclic_size):
            nkey = neighbor.key
            if visited.has(nkey): continue
            if not enterable.has(nkey): continue
            visited[nkey] = true
            parent[nkey] = current.key
            queue.push((enterable[nkey], dist + 1))

    # queue が空になった → 最後の距離層に goal があれば
    if best_goal:
        return rebuild_path(best_goal, parent)
    return []
```

**tiebreak の動作**: BFS は距離 0,1,2,... と順に展開。距離 d で始めて goal を発見したら `best_goal` に記録し、同距離 d の全ノードを処理し終えるまで継続。距離 d+1 に進む時点で、距離 d に発見した goal の中で最大成分を持つものを返す。
これにより **「最短経路の中で最大の連結領域を生む接続先」** が選択される。

計算量: 最悪 Θ(N)（全域探索）。ただし多くの場合、goal 到達までに探索する範囲は経路長のオーダー。

### 3. DSU 操作

```
make_set(key):
    if parent.has(key): return
    parent[key] = key
    comp_size[key] = 1
    comp_rep[key] = cell_by_key[key]

find(key):
    if parent[key] != key:
        parent[key] = find(parent[key])    # 経路圧縮
    return parent[key]

union(a, b):
    ra = find(a)
    rb = find(b)
    if ra == rb: return
    # サイズによる union（小を大に付ける）
    if comp_size[ra] < comp_size[rb]: swap(ra, rb)
    parent[rb] = ra
    comp_size[ra] += comp_size[rb]
    root_count -= 1
```

`comp_rep[ra]` は union 後も有効（ra が root になり続けるため）。

## 計算量

| 段階 | 計算量 | 備考 |
|------|--------|------|
| init_dsu | Θ(N) | floor 全体 BFS（1 回限り） |
| DSU build | O(N α(N)) | make_set / union |
| 反復: targets 列挙 | O(C) | C = 成分数、N より十分小 |
| 反復: BFS tiebreak | O(N) worst, O(path²) typical | 壁込みの全 cell 探索 |
| 反復: 壁削除 + union | O(L) | L = 経路長、α(N) 付き |
| **全体** | **O(N + C × N)** → **O(C × N)** | — |

### 現行比

| | 現行 | 提案 |
|---|------|------|
| 初期化 | なし | Θ(N) 1 回 |
| 反復あたり floor 再 BFS | Θ(N) | **不要**（DSU で代替） |
| 反復あたり path BFS | Θ(N) | Θ(N)（同一。ただし tiebreak 付き） |
| total | Θ(C × 2N) | Θ(N + C × N) |
| 定数倍改善 | — | **約 1/2**（floor BFS 分削減） |
| 最大成分選好 | なし | **あり** |

C が N に比例して増える最悪ケース（floor が 1 cell ずつ壁で分断）では O(N²) にとどまる。
しかし実際の map 生成では symmetric distribution により C は精々数十程度。

現実的な R=9 (N=361) なら:
- 現行: 反復あたり floor BFS (max ~180 cell) + cell BFS (361 cell) = ~540 cell 走査
- 提案: 反復あたり cell BFS (361 cell) = ~360 cell 走査
- 約 1/3 削減（floor BFS が軽いため）。成分数が少なければ反復数も少なく、
  差は大きくない。R=21 (N=1849) では差が開く。

## tiebreak の正当性

**要件**: 「最短箇所の壁のうち削除したあとの連結領域結果の長さが最大になる壁 cell を削除する」

**実現方法**: 同一 BFS 距離の全 goal cell を評価。goal cell の属する成分サイズを DSU から
取得し、最大のものを選択。

**なぜこれで要件を満たすか**:
- 最短経路の距離 d の壁を削除した場合、統合後の成分サイズ = `size(comp0) + size(comp_goal) + |path|`
- d が同一なら `size(comp0)` と `|path|` は定数 → `size(comp_goal)` の最大化が統合後サイズ最大化と等価
- tiebreak BFS は距離 d の全 goal を走査し、`comp_size` 最大のものを選ぶ

## 局所 BFS（追加検討）

DSU 化により floor 再 BFS は不要になるが、path BFS の局所化も可能:

**boundary BFS**: component の全 cell から BFS する代わりに、壁に隣接する boundary cell だけを
起点にする。成分内部を BFS が通過する無駄を省く。

```
boundary_cells = [c in component | any neighbor is wall]
path = shortest_path_with_tiebreak(boundary_cells, targets, ...)
```

boundary BFS は DSU 管理下で boundary set を維持すれば O(境界長) で更新可能。
ただし実装複雑度が上がるため、まずは DSU + tiebreak BFS を実装し、効果測定後に判断する。

## 実装インターフェース

既存 API シグネチャは変更しない:

```
static func restore_connectivity(data) -> Array       # 変更なし
static func restore_terminal_connectivity(data, terminals) -> Array  # 変更なし
```

内部実装差し替えのみ。DSU は `hex_map_generator.gd` の内部 helper として実装するか、
新規ファイル `hex_disjoint_set.gd` として分離する。

## テスト計画

既存 `_test_restore_connectivity_*` 系テストがパスすることを確認した上で、以下を追加:

1. **最大成分 tiebreak の検証** — 同距離に 2 成分がある配置で、大きい方に接続されること
2. **DSU 統合の正しさ** — 壁削除後の成分数が正しく減ること
3. **現行と同一結果（tiebreak 非発動時）の検証** — tiebreak が不要な単純配置で現行と同じ wall 削除結果になること
4. **Toric 経路との統合** — 境界越えの最短経路が DSU 下でも正しく扱われること
