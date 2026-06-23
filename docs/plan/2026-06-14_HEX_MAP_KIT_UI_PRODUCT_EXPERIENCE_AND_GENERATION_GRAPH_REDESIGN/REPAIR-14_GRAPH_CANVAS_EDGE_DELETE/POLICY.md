# REPAIR-14 Policy

## 採用判断

edge は graph 上の first-class selectable object として扱う。

Delete action は最低2経路を持つ。

- keyboard: `Delete`
- visible action: selected edge toolbar button

## 不採用判断

| item | decision | reason |
|---|---|---|
| context menu only | reject | 発見性と信頼性が弱い。 |
| node delete as workaround | reject | graph 修正の粒度が粗すぎる。 |
| silent edge delete | reject | 何が消えたか分からない。 |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| selected edge | one active edge selection | node selection と衝突 | selection snapshot |
| delete action | selected edge がある時だけ enabled | 誤削除 | disabled state test |
| graph revision | edge delete で進む | stale cache が残る | revision increment test |
| dirty nodes | target/downstream dirty | Generate が古い cache を使う | dirty propagation test |
| undo future | deletion event が明確 | undo不能 | event record design |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| context menu | secondary only | 既存操作として残せる | toolbar/keyboard安定後 | primary not menu-only |
| Remove button | node remove のまま | edge remove と混ぜない | separate delete edge button | label/action proof |

## completion criteria

- edge selection が snapshot で確認できる。
- selected edge delete が UI test で確認できる。
- graph dirty / validation state が更新される。
- edge deletion の proof が context menu に依存しない。

