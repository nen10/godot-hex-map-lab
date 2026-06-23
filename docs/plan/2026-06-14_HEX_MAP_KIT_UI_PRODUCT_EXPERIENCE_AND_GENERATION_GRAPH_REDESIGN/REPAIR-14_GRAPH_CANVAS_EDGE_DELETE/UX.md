# REPAIR-14 UX

## user goal

ユーザーは間違って接続した edge だけを消したい。node 自体を削除したり、graph を作り直したりしたくない。

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. edge の右クリック menu | medium | high | medium | reject as primary | menu が壊れると操作不能。 |
| B. edge click selection | high | medium | medium | adopt | 何を消すかが見える。 |
| C. Delete key | high | low | low | adopt | Godot editor 操作として自然。 |
| D. toolbar remove edge | high | low | medium | adopt | shortcut を知らなくても使える。 |

## expected experience

1. ユーザーが edge をクリックする。
2. edge が selected highlight になる。
3. toolbar に `Delete Edge` が有効表示される。
4. Delete key または button で edge が消える。
5. 接続先 node と downstream が dirty / invalid 状態を更新する。

## visual state

| state | 表示 |
|---|---|
| normal edge | 通常線 |
| hover edge | 少し強調 |
| selected edge | 明確な highlight |
| invalid edge | error color / warning |
| deleted edge | graph から消え、接続先 warning が更新 |

## rejected UX

- node を削除しないと edge を消せない。
- context menu だけに依存する。
- edge delete 後に graph state が古いまま残る。

