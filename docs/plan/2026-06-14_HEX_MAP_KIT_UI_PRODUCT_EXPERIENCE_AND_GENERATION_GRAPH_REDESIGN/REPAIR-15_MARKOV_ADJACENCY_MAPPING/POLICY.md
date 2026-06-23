# REPAIR-15 Policy

## 採用判断

旧 Generate の Markov / adjacency は、旧 UI state を移植するのではなく、Build graph の node params に分解して対応付ける。

## Mapping Matrix

初期仮説:

| 旧 Generate 概念 | graph node | param group | 備考 |
|---|---|---|---|
| Markov Mesh / wall variation | `Wall Field` | method, probability, seed, topology | terrain を入力し terrain を出す |
| symmetric / toric wall | `Wall Field` | topology / symmetry option | Shape orientation / topology と矛盾しないこと |
| terminal connectivity | `Connectivity` | terminals, method | optional selection input と対応 |
| overlay adjacency | `Item Generator` | placement method, adjacency rules | overlay output を作る |
| adjacency reference | `Overlay Filter` or `Source Overlay` | item key / reference overlay | overlay input を明示する |
| item limit | `Item Generator` | limit / pool / rule | selection 範囲に対して適用 |

## 不採用判断

| item | decision | reason |
|---|---|---|
| old state evaluator の丸写し | reject | dynamic graph と合わない。 |
| raw mode text を specification にする | reject | UX/API の意味が不明瞭。 |
| new generation engine | reject | core static reuse の原則に反する。 |
| sample-only parity | reject | 任意 graph params の証明にならない。 |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Wall Field params | runner read key と一致 | UI値が効かない | param propagation test |
| adjacency rules | parse result が runner に渡る | ルール変更が無効 | changed rule changes output |
| overlay reference | overlay input 型が明示 | terrain/overlay 混同 | connection validation |
| seed handling | deterministic | Generate ごとに揺れる | same seed same result |
| topology | Shape と矛盾しない | toric optionが無効 | topology-specific test |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| old Generate terms | docs-only mapping | 相談時の照合に必要 | graph labels安定後 | mapping matrix |
| dedicated Markov node | defer | 必要性未確定 | Wall Fieldで表現不能なら | design review |
| raw rule editor | keep only if typed validationあり | adjacency rule入力に必要な場合がある | structured UI available | invalid rule warning |

## completion criteria

- 旧 Generate の主要 Markov / adjacency 設定が mapping matrix で説明できる。
- graph node params と runner read keys が一致する。
- adjacency rule 変更が output 差分を生む。
- state evaluator の制約が node schema / derived state として表現される。

