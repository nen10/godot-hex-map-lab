# REPAIR-13A Policy

## 採用判断

node add row は graph 下部に置き、`Anchor / Build / Select` に分類する。

Source は UI 上で `Source Terrain` / `Source Overlay` に分ける。

## Resource / API 境界

| area | owns | must not own |
|---|---|---|
| row UI | button layout / grouping | graph run semantics |
| Source inspector | output type 表示 | Source data resolution 全体 |
| graph model | typed Source params | UI-only labels |
| state evaluator | connectable next node | row layout |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Source output type | visible in title or chip | Source が何でも入るように見える | snapshot |
| row grouping | Anchor/Build/Select order | node の意味が混ざる | layout snapshot |
| Compose | primary row に出さない | Result と混同 | absence proof |
| add row | graph 下部にある | palette が主役に戻る | screen snapshot |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| legacy Source label | avoid | 型が曖昧 | existing graph migration handled | source title proof |
| old palette | remove or demote | 二重入口になる | row stable | no duplicate primary palette |
| compact text | avoid | 可読性低下 | none | min readable size check |

## completion criteria

- row が graph 下部に配置される。
- `Source Terrain` と `Source Overlay` が明確に追加できる。
- Source node の出力型が inspector / node header で分かる。
- Add Node row は Apply/Revert 操作と混ざらない。

