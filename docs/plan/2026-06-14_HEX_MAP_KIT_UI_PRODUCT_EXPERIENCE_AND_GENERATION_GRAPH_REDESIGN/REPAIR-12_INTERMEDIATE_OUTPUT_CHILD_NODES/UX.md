# REPAIR-12 UX

## user goal

ユーザーは graph の中間 output を見て、どの node がどの terrain / overlay を作っているかを確認したい。ただし、確認しただけで本番 layer が書き換わってはいけない。

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. 中間 output は表示しない | low | medium | low | reject | graph debug ができない。 |
| B. 中間 output を main layer に一時適用 | medium | high | medium | reject | preview と apply の境界が壊れる。 |
| C. 中間 output を child node として表示 | high | medium | medium | adopt | inspectable かつ main layer を守れる。 |
| D. 中間 output を小サムネイルだけにする | low | high | low | reject | viewport proof にならない。 |

## expected experience

1. ユーザーが graph の中間 node を選ぶ。
2. `Generate` 後、その node の output が child preview として viewport に出る。
3. Scene tree 上または Build UI 上で「generated intermediate」であることが分かる。
4. Result preview / Apply までは main target layer の document に混ざらない。
5. 次の Generate で古い中間 preview は置換される。

## visual labeling

中間 output child は、通常 layer と誤認されない表示が必要。

| 表示 | 意味 |
|---|---|
| `Intermediate` | Apply 対象ではない |
| source node id | どの node output か |
| run revision | 最新 run か stale か |
| output type | terrain / overlay |

## rejected UX

- 中間 output を silent に main target layer へ混ぜる。
- Scene tree に古い中間 output を増殖させる。
- サムネイルだけで中間 preview とする。

