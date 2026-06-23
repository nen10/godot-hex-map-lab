# REPAIR-12 Policy

## 採用判断

中間 output は managed child node として扱う。

```text
BuildHexMapLayer
  Generated preview document / final target
  _BuildIntermediateOutputs
    node_<id>_terrain
    node_<id>_overlay
```

実際の node 名は実装時に決めるが、owner は target layer 側に寄せ、workspace 全体に散らさない。

## 不採用判断

| item | decision | reason |
|---|---|---|
| main document への中間混入 | reject | Apply/Revert の意味を破壊する。 |
| cache-only 中間 output | reject | viewport inspection にならない。 |
| append-only child | reject | 古い output が残り続ける。 |
| user manual layer と同じ扱い | reject | intermediate は generated/run-owned。 |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| intermediate child parent | target layer 配下に集約 | scene tree 迷子 | parent path test |
| child lifecycle | run replacement | old child 増殖 | rerun replace test |
| child data | source node id / output type を保持 | 何の output か不明 | metadata snapshot |
| main target document | Apply まで中間 output を混ぜない | preview が本番 data を汚染 | document unchanged test |
| stale state | graph revision change で stale | 古い output を最新と誤認 | stale indicator test |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| no intermediate selected | allow no child | Result preview だけでよい graph がある | none | no-child run succeeds |
| stale child visible | allow with label | comparison/debug に有用 | user clears or reruns | stale label proof |
| missing output | no child + warning | invalid node output を scene に出さない | fix graph | warning snapshot |

## ownership rules

- Intermediate child は user-authored layer ではない。
- Paint / manual edit の対象にしない。
- Apply は intermediate child を本番化しない。Apply は Result preview を確定する。
- Remove / cleanup は run-owned child のみに作用する。

