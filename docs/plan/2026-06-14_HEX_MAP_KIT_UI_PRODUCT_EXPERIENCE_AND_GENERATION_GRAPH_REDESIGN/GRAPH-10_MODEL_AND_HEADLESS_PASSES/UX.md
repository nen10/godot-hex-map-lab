# GRAPH-10 UX（API ergonomics・headless）

GRAPH-10 は UI を持たない。ここでの "UX" は **後段の canvas(`GRAPH-11`) と test が使う API の使い心地**。

## 使う人

- `GRAPH-11` の Build canvas（node を置き・繋ぎ・run する）。
- test / runtime build（`RUNTIME-50`）。

## 達成したい API 体験

- graph を **data（Dictionary）として組み立て**られる：`add_node(graph, id, type, params)` / `add_edge(graph, from, to, to_port)`。
- run 前に **`validate(graph)` が人が読めるエラー**（どの edge が型不一致か、どこが cycle か、どの入力が未接続か）を返す。
- `run(graph, context)` が **node_id → output** の Dictionary を返し、任意 node の中間 output を取り出せる（preview / 次 node 入力の素地）。
- node の追加は **registry に1エントリ**で済む（inputs / output / run Callable）。

## UX Candidate Matrix（API 形）

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| run の戻り | A: `{node_id: output}` 全 cache / B: 最終 node のみ | **A** | 中間 output を canvas/preview が参照する（背骨要件）。 |
| validate の戻り | A: `{ok, errors:[{code,node,edge,msg}]}` / B: bool のみ | **A** | 失敗 node を可視化（`GRAPH-13` の「どの node が悪いか」に接続）。 |
| node 入力解決 | A: 入力ポート名 → 上流 output / B: 位置引数 | **A** | 多入力(`compose`)を名前で扱える。 |
| seed | A: node param + context base seed の合成 / B: node param のみ | **A** | 「同一 graph を別 seed で」(`GRAPH-13` 束生成)に備える。 |

## 避ける体験

- run/validate が原因不明で失敗する（error は code + 対象 node/edge を持つ）。
- node 追加に複数ファイル横断の boilerplate が要る（registry 1 箇所に集約）。
- 入力 Resource を破壊的に書き換える（Source は読み取り / 複製、`POLICY.md` invariant）。
