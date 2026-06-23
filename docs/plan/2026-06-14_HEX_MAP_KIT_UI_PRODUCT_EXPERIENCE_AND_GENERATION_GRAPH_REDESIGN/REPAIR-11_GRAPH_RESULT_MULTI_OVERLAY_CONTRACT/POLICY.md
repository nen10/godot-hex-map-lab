# REPAIR-11 Policy

## 採用判断

`Result` は `terrain` 1本と `overlay_inputs[]` を受ける終端 node とする。

```text
Result
  terrain: terrain
  overlays:
    - overlay[0]
    - overlay[1]
    - overlay[n]
```

## 不採用判断

| item | decision | reason |
|---|---|---|
| `Result` input としての `result` | reject | 終端の入れ子化で projection 責務が曖昧になる。 |
| primary `Compose` | reject for primary | final composition は Result に寄せる。 |
| overlay の silent merge | reject | 別 layer として inspection / Apply/Revert できない。 |
| thumbnail-only completion | reject | viewport / document projection を証明しない。 |

## Resource / API 境界

| area | owns | must not own |
|---|---|---|
| graph model | Result input slot と edge contract | viewport apply side effect |
| runner | terrain / overlay output cache | layer selection policy |
| projection | document snapshot と layer apply | graph node authoring |
| UI | overlay input 一覧と警告 | hidden merge |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Result terrain input | exactly one required terrain | terrain 無しで成功扱い | missing terrain test |
| Result overlay inputs | zero or more overlay inputs | overlay が欠落 | multi-overlay result test |
| overlay order | deterministic | Generate ごとに順序が変わる | stable order test |
| item key conflicts | warning visible | 上書きに気づけない | conflict warning test |
| Apply/Revert | terrain + overlay snapshot | overlay だけ残る/消える | revert restores overlays |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Result without overlay | allow | terrain-only graph は有効 | none | terrain-only Result test |
| Result missing terrain | invalid | viewport projection の主体がない | none | Generate disabled/fails clearly |
| legacy Compose | hide/defer | primary flow を単純化する | Merge Overlay 等へ再設計 | no primary Compose button |

## completion criteria

- `Result` の schema が `terrain + overlay_inputs[]` として読める。
- `Result` は `result` input を拒否する。
- 複数 overlay が separate generated overlay として document に残る。
- viewport proof が terrain と全 overlay を含む。

