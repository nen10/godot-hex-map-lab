# REPAIR-13A UX

## user goal

ユーザーは Build graph で次に追加する node を、内部 node type 名ではなく「layer 生成の流れ」から選びたい。

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. 左 palette のまま | low | medium | low | reject | graph 下部に作業 flow が集まらない。 |
| B. row を graph 下部へ移動 | high | medium | medium | adopt | 追加操作と graph 編集面が近い。 |
| C. 全 button を平置き | medium | medium | low | reject | Source / Result / Filter の意味が混ざる。 |
| D. role group で分類 | high | low | medium | adopt | node の位置付けが読める。 |

## row design

```text
Add Node
  Anchor: Source Terrain | Source Overlay | Shape | Result
  Build:  Wall Field | Connectivity | Item Generator
  Select: Terrain Filter | Overlay Filter | Selection Operator
```

## group meaning

| Group | 意味 |
|---|---|
| Anchor | graph の起点と終点 |
| Build | terrain / overlay を生成・変換 |
| Select | cell selection を作る・加工 |

`Result` は base ではなく終点 anchor として置く。

## Source UX

Source は「何でも入る」node として見せない。

最低限表示:

- node title: `Source Terrain` or `Source Overlay`
- output type chip: `terrain` / `overlay`
- source kind: layer / document / resource
- connectable next nodes

## rejected UX

- `Source` button 1つで output type を後から探させる。
- `Compose` を primary row に残す。
- Add Node row と Apply/Revert row を混ぜる。
- 12px など読めない文字サイズで row を圧縮する。

