# Source / Terrain Filter / Overlay Filter 分離設計

## 目的

現在の Build graph では、`Source` が「何でも入る入口」に見え、`Region Filter` も terrain と overlay のどちらを対象にしているのか曖昧になっている。

この曖昧さは、Generate の結果が viewport に出ない問題とは別に、今後の graph 操作性と validation を壊す。特に Overlay Filter の `item key` UX は、Source と出力型の設計が固まっていないと成立しない。

## 原則

- Source は入力元ではなく、graph 内の型付き出力の起点として扱う。
- Terrain Filter は terrain output だけを受ける。
- Overlay Filter は overlay output だけを受ける。
- Overlay Filter の `item key` は raw text ではなく、upstream overlay から導出される候補として扱う。
- invalid な接続は、Generate 実行時に失敗する前に graph 上で見える必要がある。
- サンプルにだけ合わせた Source 設計は採用しない。

## Node Add Row の整理

graph 下部に置く対象は、`batch / Apply / Revert / Remove` ではない。

下部 row は、ノード追加と生成フローの位置付けを整理するための領域にする。

推奨する並び:

| Group | Buttons |
|---|---|
| Anchor | `Source Terrain`, `Source Overlay`, `Shape`, `Result` |
| Build | `Wall Field`, `Connectivity`, `Item Generator` |
| Select | `Terrain Filter`, `Overlay Filter`, `Selection Operator` |

UI 上の表示は短くしてよいが、各 button の tooltip / validation label では出力型を明示する。

`Compose`はprimary rowには置かない。final compositionは`Result`に寄せる。詳細は [NODE_ADD_ROW_AND_PORT_CONTRACT.md](./NODE_ADD_ROW_AND_PORT_CONTRACT.md) を参照する。

## Source の設計案

### 案 A: 単一 Source + output type chip

`Source` ノードは 1 種類のまま、node inspector で output type を選ぶ。

利点:

- ノード種類が増えにくい。
- 内部 model は単純に保てる。

問題:

- graph 初見で Source の型がわかりにくい。
- `Source` が「何でも入る」という現状の誤解を残しやすい。
- Add row で terrain / overlay の生成フローを説明しにくい。

### 案 B: UI 上は Source Terrain / Source Overlay、内部は typed Source

Add row では `Source Terrain` と `Source Overlay` を分ける。内部 model では同じ Source node に `output_type` を持たせる。

利点:

- ユーザーには型が明確に見える。
- 内部 schema を大きく増やさずに済む。
- Terrain Filter / Overlay Filter の分離と自然につながる。

問題:

- 既存 Source ノードの表示名と migration 方針が必要。

現時点の推奨:

`案 B` を第一候補にする。Source分離案は棄却しない。

### 案 C: SourceTerrain / SourceOverlay を完全に別 node type にする

利点:

- validation が最も単純。
- UI と内部 model が一致する。

問題:

- node type が増える。
- 既存 Source の扱いが migration になりやすい。
- Resource schema を増やす方向に寄る。

現時点では、最初の修正としては過剰に見える。

## Terrain Filter

Terrain Filter は terrain map / terrain selection を対象にする。

入力:

- terrain output
- terrain selection output

出力:

- selection output

扱える条件:

- terrain kind
- region id
- coordinate range
- distance from coordinate / terminal / selection
- shape-derived region

受け付けないもの:

- overlay item key
- item generator output の item identity
- object document state

Validation:

| Input | 判定 |
|---|---|
| terrain output | valid |
| terrain selection output | valid |
| overlay output | invalid |
| result output | terrain part を明示抽出できる場合のみ valid |
| unknown output | unconfigured |

## Overlay Filter

Overlay Filter は overlay / item placement を対象にする。

入力:

- overlay output
- result output の overlay part

出力:

- selection output

扱える条件:

- item key
- item category
- tag
- item placement source
- distance from item
- distance from coordinate / selection

受け付けないもの:

- terrain kind を直接指定する filter
- wall / floor の terrain 分類

Validation:

| Input | 判定 |
|---|---|
| overlay output | valid |
| result output with overlay | valid |
| terrain output | invalid |
| selection only | item key 候補が無ければ unconfigured |
| unknown output | unconfigured |

## Overlay Filter の item key UX

`item key` は自由入力にしない。

候補の取得元は次の優先順で検討する。

1. upstream Item Generator の planned item keys
2. upstream overlay output cache の actual item keys
3. external overlay Resource の declared item keys
4. unknown state として選択不能表示

未実行 graph でも item key を選びたい場合は、`planned item keys` を Derived Graph State に含める必要がある。

実行済み output cache だけに依存すると、Generate 前に filter 設定できないため UX が弱くなる。

## Region Filter の扱い

`Region Filter` という名前は曖昧なので、最終 UI では残さない方向を第一候補にする。

既存 graph の扱い:

| 既存状態 | 変換先 |
|---|---|
| terrain input の Region Filter | Terrain Filter |
| overlay input の Region Filter | Overlay Filter |
| item key を使う Region Filter | Overlay Filter |
| input が未接続 | unconfigured filter として明示 |
| input type が不明 | validation warning |

互換性は現時点の主目的ではないが、既存の開発中 graph を読み込んだ時に無音で壊れる状態は避ける。

## Derived Graph State で持つべき情報

動的にノードが増減するため、全状態を固定 FSM として列挙しない。

代わりに、graph から毎回導出する。

必要な derived state:

| State | 用途 |
|---|---|
| node output type | downstream validation |
| connection validity | invalid edge 表示 |
| terminal outputs | Result が無い場合の promote 候補 |
| selected output type | Promote UI / Generate projection |
| planned overlay keys | Overlay Filter item key 候補 |
| actual overlay keys | 実行済み cache からの候補 |
| missing required params | Generate 前 validation |
| stale output nodes | UI 値変更後の再生成要求 |

## Generate との関係

Generate は次の順で処理する必要がある。

1. active layer / document / graph context を同期取得する。
2. graph derived state を再評価する。
3. invalid / unconfigured state があれば Generate を止めるか、明示 warning を出す。
4. UI parameter を graph model に flush する。
5. graph run state を開始する。
6. output cache を作る。
7. Result または deterministic promote rule で document に反映する。
8. active layer の viewport display に反映する。
9. preview state を `preview_pending` にする。

Source / Filter の型が曖昧なままだと、3 と 7 が安定しない。

## Result との関係

`Result`は複数overlayを認識する必要がある。

ただし、`result` typeをinputとして受け取らない。`Result`は終端であり、`terrain`と`overlay_inputs[]`からviewport projection対象を作る。

初期設計では`Compose`を`Result`に代替させ、primary rowには出さない。

## 打ち合わせが必要な不明点

1. `Source Terrain` / `Source Overlay` を UI button として分け、node titleも分ける案でよいか。
2. 内部 model は typed Source でよいか、完全に別 node type にするか。
3. `Region Filter` 名を UI から削除してよいか。
4. Overlay Filter の item key 候補は、planned keys と actual keys のどちらを優先するか。
5. Result node の overlay input は明示slot方式でよいか。
6. Result node が overlay を含まない場合、Overlay Filter downstream を invalid にするか unconfigured にするか。
7. 既存 graph の Region Filter をどこまで自動変換するか。
