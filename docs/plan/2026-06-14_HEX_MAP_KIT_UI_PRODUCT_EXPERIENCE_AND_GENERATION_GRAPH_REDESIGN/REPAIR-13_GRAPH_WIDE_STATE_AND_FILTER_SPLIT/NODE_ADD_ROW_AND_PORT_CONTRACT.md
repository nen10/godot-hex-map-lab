# Node Add Row と Port 契約

## 目的

Build graph の混乱を止めるため、node 追加 row の分類と、各 node の入口・出口を明文化する。

ここでは「何となく接続できる graph」を採用しない。各 node は、受け取る型と出す型を明確に持つ。

## 設計判断

### Source は二つに分ける

`Source` 分離案は棄却しない。第一候補として採用する。

| 層 | 扱い |
|---|---|
| UI button | `Source Terrain` と `Source Overlay` に分ける |
| graph canvas 表示 | `Source Terrain` / `Source Overlay` として見せる |
| 内部 node model | typed Source node + `output_type` |
| validation | `output_type` で判定 |

これにより、ユーザーには入口の型が明確に見え、内部実装は過剰に分裂しない。

### Result は複数 overlay を認識する

`Result` は複数の overlay input を認識できる必要がある。

ただし「同じ port に複数 edge が刺さったら何となく拾う」ではなく、graph model 上で `overlay_inputs[]` として保持する。

| 案 | 内容 | 評価 |
|---|---|---|
| A | `overlay 1`, `overlay 2`, `overlay +` のように明示 slot を増やす | 認識しやすく、debug しやすい |
| B | 1つの overlay port に複数接続を許す | 見た目は軽いが、順序と validation が見えにくい |

現時点の推奨は A。overlay の合成順序、優先順位、警告を UI に出しやすい。

### Result は result を受け取らない

`Result` node は `result` input を受け取らない。

理由:

- `result` は graph の終端契約であり、中間 data type として扱うと入れ子構造になる。
- `Result -> Result` が可能になると、どちらが viewport projection の責任を持つか曖昧になる。
- `Compose` が `result` を作り、`Result` がそれを受ける設計にすると、終端と合成の責務が分裂する。

必要な場合は、`result` を直接つなぐのではなく、明示的な抽出 node を検討する。

| 必要な操作 | 将来案 |
|---|---|
| result から terrain を再利用 | `Extract Terrain` |
| result から overlay を再利用 | `Extract Overlay` |
| result を外部 asset として読む | `Source Terrain` / `Source Overlay` に変換して読む |

### Compose は初期設計では Result に代替させる

`Compose` は primary node add row には置かない。

初期設計では `Result` が final composition を担当する。

| Node | 責務 |
|---|---|
| `Result` | terrain + overlay[] を受け取り、viewport preview / apply の対象を確定する |
| `Compose` | 初期 primary row では非表示。中間合成が必要になった時だけ再検討する |

`Compose` を残すと、`Compose` と `Result` の差が UI 上で説明しにくい。現状の混乱を解消する段階では、終端合成は `Result` に一本化する。

## Node Add Row の分類

ユーザー案:

```text
source, shape, result /
wall, Item Generator, connectivity /
terrain filter, overlay filter, operator
```

この分類は意味がある。

ただし group 名を `Base` にすると、`Result` が入口側に見えてしまう。したがって group 名は `Anchor` とする。

推奨 row:

```text
Add Node
  Anchor: Source Terrain | Source Overlay | Shape | Result
  Build:  Wall Field | Connectivity | Item Generator
  Select: Terrain Filter | Overlay Filter | Selection Operator
```

| Group | 意味 | Buttons |
|---|---|---|
| Anchor | graph の起点と終点を置く | `Source Terrain`, `Source Overlay`, `Shape`, `Result` |
| Build | terrain / overlay を生成・変換する | `Wall Field`, `Connectivity`, `Item Generator` |
| Select | selection を作る・加工する | `Terrain Filter`, `Overlay Filter`, `Selection Operator` |

この分類では `Result` は「base」ではなく「終点 anchor」として扱う。

## Port Type

| Type | 意味 | 備考 |
|---|---|---|
| `terrain` | hex cell の terrain state | floor / wall / region など |
| `overlay` | item / decoration / placement layer | item key を持つ |
| `selection` | hex cell の集合・mask | filter / operator の出力 |
| `result` | viewport projection 対象の最終 bundle | 通常 input には使わない |

`result` は終端であり、中間接続 type として乱用しない。

## Node I/O 契約

| Node | Inputs | Outputs | 備考 |
|---|---|---|---|
| `Source Terrain` | none | `terrain` | 既存 layer / resource / document から terrain を graph に入れる |
| `Source Overlay` | none | `overlay` | 既存 overlay / item placement を graph に入れる |
| `Shape` | none | `terrain` | 新規 terrain 領域を作る |
| `Wall Field` | `terrain`, optional `selection` | `terrain` | terrain を壁・床などに変換する |
| `Connectivity` | `terrain`, optional `selection` | `terrain` | 到達性を補正する |
| `Terrain Filter` | `terrain` | `selection` | terrain 条件で cell 集合を作る |
| `Overlay Filter` | `overlay` | `selection` | item key など overlay 条件で cell 集合を作る |
| `Selection Operator` | `selection A`, `selection B` | `selection` | union / intersect / subtract |
| `Item Generator` | `terrain`, optional `selection`, optional `overlay` | `overlay` | terrain 上に item overlay を生成する |
| `Result` | `terrain`, zero-many `overlay` | terminal `result` | final composition と viewport projection の対象 |

## Result の詳細契約

`Result` は表示対象を確定する node。

入力:

- required: `terrain`
- optional: `overlay_inputs[]`

出力:

- terminal `result`

接続禁止:

- `result -> Result`
- `Result -> Result`
- `Result -> Terrain Filter`
- `Result -> Overlay Filter`

`Result` の terminal `result` は、UI snapshot / preview state / Generate projection のための出力であり、通常の downstream node に接続するための型ではない。

## Multiple Overlay の扱い

`Result` の overlay は配列として扱う。

```text
Result
  terrain: terrain
  overlays:
    - overlay from Item Generator A
    - overlay from Item Generator B
    - overlay from Source Overlay
```

必要な derived state:

| State | 意味 |
|---|---|
| `result_terrain_input` | Result に入る terrain edge |
| `result_overlay_inputs[]` | Result に入る overlay edge 一覧 |
| `overlay_order[]` | 合成順序 |
| `duplicate_item_key_warnings[]` | 同一 item key の衝突 |
| `missing_terrain_error` | terrain 入力がない |

overlay の順序が意味を持つ場合、UI で順序を見せる。順序が意味を持たないなら、graph revision と node order で deterministic に並べる。

## Item Generator の位置付け

`Item Generator` は `result` を作らない。

出すのは `overlay`。

これにより、複数の Item Generator を `Result` に並列接続できる。

```text
Shape -> Wall Field -> Connectivity -> Result.terrain
Connectivity -> Terrain Filter -> Item Generator A -> Result.overlay[0]
Connectivity -> Terrain Filter -> Item Generator B -> Result.overlay[1]
Source Overlay -> Overlay Filter -> Selection Operator -> Item Generator C -> Result.overlay[2]
```

## Compose を primary row に置かない理由

`Compose` を `Result` と並べると、ユーザーは次を判断できなくなる。

- viewport に出るのは Compose なのか Result なのか。
- Compose 後に Result が必要なのか。
- Compose の output type が `result` なら、Result は result を受け取るのか。
- Compose の output type が overlay なら、Compose という名前が正しいのか。

したがって、今の段階では `Compose` を primary row から外す。

将来、中間合成が必要になった場合は、`Compose` ではなく、用途が明確な node 名を再検討する。

| 将来 node | 用途 |
|---|---|
| `Merge Overlay` | 複数 overlay を 1 overlay にまとめる |
| `Extract Terrain` | result-like source から terrain を取り出す |
| `Extract Overlay` | result-like source から overlay を取り出す |

## Validation Rules

| Connection | 判定 |
|---|---|
| `terrain -> Terrain Filter` | valid |
| `overlay -> Terrain Filter` | invalid |
| `overlay -> Overlay Filter` | valid |
| `terrain -> Overlay Filter` | invalid |
| `selection -> Selection Operator` | valid |
| `terrain -> Result.terrain` | valid |
| `overlay -> Result.overlay[n]` | valid |
| `result -> Result` | invalid |
| `result -> filter` | invalid |

## 打ち合わせが必要な不明点

1. `Source Terrain` / `Source Overlay` は UI 表示だけでなく node title も分けるか。
2. `Result` の overlay input は明示 slot 方式でよいか。
3. overlay 合成順序は UI で並べ替える必要があるか。
4. `Item Generator` の optional overlay input は既存 overlay への追加用途として必要か。それとも常に overlay delta を出すだけにするか。
5. `Compose` を完全削除候補にするか、advanced node として隠すか。

