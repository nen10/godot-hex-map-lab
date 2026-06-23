# REPAIR-13 UX

## 目的

Build graphの操作を、node typeの暗記ではなく「layer生成の流れ」として理解できるようにする。

ユーザーは以下を自然に判断できる必要がある。

- どのnodeがterrainを作るのか。
- どのnodeがoverlay/itemを作るのか。
- どのnodeがselectionを作るのか。
- `Source`が何の型をgraphへ入れているのか。
- `Generate`後の結果がpreview pendingなのか、appliedなのか、projection failedなのか。

## node追加row

graph下部へ移す対象は、batch / Apply / Revert / Removeではなく、node追加UI。

想定row:

```text
Add Node
  Anchor: Source Terrain | Source Overlay | Shape | Result
  Build:  Wall Field | Connectivity | Item Generator
  Select: Terrain Filter | Overlay Filter | Selection Operator
```

buttonはlayer生成段階でgroup化する。

| group | buttons | 意味 |
|---|---|---|
| Anchor | `Source Terrain`, `Source Overlay`, `Shape`, `Result` | graphの起点と終点を置く。 |
| Build | `Wall Field`, `Connectivity`, `Item Generator` | terrain / overlay候補を生成・変換する。 |
| Select | `Terrain Filter`, `Overlay Filter`, `Selection Operator` | selectionを作る・加工する。 |

## Source UX

`Source`は「何でも入る」ように見せない。

最低限、node headerまたはinspectorに以下を表示する。

- output type: `terrain` / `overlay` / `result`
- source kind: `document_terrain` / `document_overlay` / `map_resource` / `overlay_resource` / `result_terrain` / `result_overlay`
- 接続できるfilter候補

UI案:

| 案 | 内容 | 評価 |
|---|---|---|
| A | `Source` buttonは1つ。node内chipでoutput typeを表示。 | 実装は小さいが、Add Node時に型が見えにくい。 |
| B | buttonは`Source Terrain` / `Source Overlay`に分ける。内部node typeは同じ。 | UI上わかりやすく、実装増加を抑えられる。 |
| C | node type自体を`Terrain Source` / `Overlay Source`へ分ける。 | 明快だがnode typeが増え、移行も大きい。 |

現時点の推奨はB。`Source`分離案は棄却しない。UI buttonとnode titleは型別に見せ、内部modelはtyped Sourceとして扱う。

詳細は [NODE_ADD_ROW_AND_PORT_CONTRACT.md](./NODE_ADD_ROW_AND_PORT_CONTRACT.md) を参照する。

## Filter UX

`Region Filter`という名前は曖昧。今後は以下へ分ける。

| node | input | output | 主な用途 |
|---|---|---|---|
| `Terrain Filter` | terrain | selection | floor/wall/any、距離、shiftなど。 |
| `Overlay Filter` | overlay | selection | item-key、occupied、距離、shiftなど。 |

`Overlay Filter`のitem-keyはraw text入力ではなく、incoming overlayが生成予定または保持しているkey候補から選ぶ。

## Result UX

`Result`はfinal compositionとviewport projectionの対象を確定する終端node。

- `terrain`を1つ受け取る。
- `overlay`を0個以上受け取る。
- `result`は受け取らない。
- `Compose`はprimary node add rowには置かず、初期設計では`Result`に代替させる。

## Preview stateの見え方

Generate後、ユーザーには少なくとも以下が区別できる必要がある。

- `preview_pending`: viewportに出ていて、Apply/Revert待ち。
- `applied`: Apply済み。
- `reverted`: Revert済み。
- `projection_failed`: outputはあるがviewportに出せていない。

この状態が見えないと、`Generate -> Apply -> Generate`のような副作用依存に気づけない。
