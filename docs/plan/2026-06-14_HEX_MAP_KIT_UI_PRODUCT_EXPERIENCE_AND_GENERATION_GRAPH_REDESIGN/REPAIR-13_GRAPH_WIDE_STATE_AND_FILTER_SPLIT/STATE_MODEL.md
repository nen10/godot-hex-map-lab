# Graph-wide State Model

## 結論

state遷移モデルは設計可能。ただし、動的に増減するnode graph全体を1つの巨大FSMにしない。

採用するのは、以下の分離。

```text
Graph Edit State
  -> Derived Graph State
  -> Run State
  -> Preview State
  -> Context State
```

graph構造とnode paramsから導出できるものは、毎回再計算する。永続的に持つのは、graph編集state、run結果、preview状態、contextだけ。

## state domains

### 1. Graph Edit State

ユーザー編集そのもの。

保持するもの:

- nodes
- edges
- selected node
- node params
- node resource refs
- graph revision

発生event:

- node add
- node remove
- edge connect
- edge disconnect
- param change
- resource ref change
- selected node change

### 2. Derived Graph State

Graph Edit Stateから導出する。保存せず、必要時に再計算する。

導出するもの:

- port type
- valid / invalid connection
- topo order
- upstream output type
- result terrain input
- result overlay inputs
- overlay merge order
- missing required input
- missing required param
- dirty node ids
- runnable node ids
- terminal outputs
- candidate Result node
- incoming overlay item-key candidates
- filter mode validity

### 3. Run State

graph実行中/実行後の状態。

```text
idle
running
cancelled
failed
generated
stale
```

`stale`は、成功run後にgraph editが入り、cacheが古くなった状態。

### 4. Preview State

viewport previewの状態。詳しくは [GENERATE_PREVIEW_STATE_MODEL.md](./GENERATE_PREVIEW_STATE_MODEL.md)。

```text
none
preview_pending
applied
reverted
projection_failed
```

### 5. Context State

Buildがどのlayer/document/graphに対して動くか。

```text
no_target
selected_layer
created_layer
document_ready
graph_ready
projection_target_ready
```

## event pipeline

```text
UI event
  -> Graph Edit State更新
  -> graph revision更新
  -> affected nodesをdirty化
  -> Derived Graph State再計算
  -> inspector / canvas / warnings更新
  -> Generate時にRun State更新
  -> outputをResultへ集約
  -> document promote
  -> viewport projection
  -> Preview State更新
```

## 動的node graphを管理できる理由

node数が増減しても、全組み合わせを状態として列挙しないため管理できる。

管理単位:

- node schema
- edge validation
- graph traversal
- derived state evaluator
- run cache
- preview state

つまり、graph全体を固定FSMにするのではなく、node schemaとgraph構造から状態を導出する。

## Node State

各nodeには以下のderived stateを持たせる。

| field | 意味 |
|---|---|
| `node_id` | graph内id |
| `node_type` | Source, Shape, Terrain Filterなど |
| `input_status` | required inputが接続済みか |
| `param_status` | 必須paramが有効か |
| `resource_status` | 必須resource refが有効か |
| `output_type` | terrain / selection / overlay / result |
| `dirty` | 再計算が必要か |
| `runnable` | runnerに渡せるか |
| `warning_ids` | inspectorに出す警告 |

## Graph Derived State

graph全体には以下を持つ。

| field | 意味 |
|---|---|
| `topo_order` | 実行順 |
| `invalid_edges` | 型不一致や存在しないport |
| `dirty_node_ids` | 再計算対象 |
| `runnable_node_ids` | 実行可能node |
| `terminal_node_ids` | downstreamを持たないnode |
| `result_node_ids` | Result node候補 |
| `result_terrain_input` | Resultに入るterrain edge |
| `result_overlay_inputs` | Resultに入るoverlay edge配列 |
| `overlay_order` | Resultでのoverlay合成順序 |
| `selected_output_type` | selected nodeのoutput type |
| `incoming_item_key_candidates` | Overlay Filter用候補 |

## invariants

- param changeは必ずgraph revisionを進める。
- param changeは該当nodeとdownstream nodeをdirtyにする。
- edge changeは接続先nodeとdownstream nodeをdirtyにする。
- Generateはstale cacheだけで成功扱いしない。
- Resultがある場合、viewport projectionはResultを優先する。
- Resultは`terrain`と`overlay_inputs[]`を受け取る。
- Resultは`result`をinputとして受け取らない。
- `Compose`は初期primary flowでは使わず、final compositionはResultに寄せる。
- Applyはviewport projectionを新規に発生させない。pending previewを確定するだけ。
- Revertはdocument snapshotとviewport displayを両方戻す。

## 設計上の注意

旧Generateのstate evaluatorをそのまま移植しない。

移植すべきなのは、旧Generateが持っていた「mode間の制約」「生成methodの選択」「param有効/無効条件」。これはnode schemaとderived graph stateで表現する。
