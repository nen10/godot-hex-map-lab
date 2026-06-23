# REPAIR-15 UX

## user goal

ユーザーは旧 Generate にあった Markov Mesh / adjacency 系の挙動を、Build graph 上でどの node に設定すればよいか理解したい。

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. 旧 Generate と同じ mode panel を graph に置く | medium | high | high | reject | graph の node model と衝突する。 |
| B. Wall / Item node に params として整理 | high | medium | medium | adopt | node の責務に沿って設定できる。 |
| C. Markov / adjacency 専用 node を即追加 | medium | medium | high | defer | まず既存 node で表現可能か確認する。 |
| D. 設定名を隠して preset 化 | low | high | low | reject | sample-only prototype に戻る。 |

## expected experience

1. ユーザーは terrain を `Shape` で作る。
2. 壁・通路の揺らぎは `Wall Field` と `Connectivity` で設定する。
3. item の隣接ルールは `Item Generator` で設定する。
4. terrain / overlay を基準にした選択は `Terrain Filter` / `Overlay Filter` で行う。
5. inspector には「旧 Generate のどの意味に相当するか」ではなく、graph node としての意味が表示される。

## mapping labels

UI ラベルは旧 Generate の raw mode 名をそのまま出さない。

| 旧概念 | graph 上の見せ方 |
|---|---|
| Markov Mesh | Wall Field の生成方式 |
| adjacency rules | Item Generator の placement rule |
| overlay adjacency reference | Overlay Filter / Item Generator の input |
| symmetric toric walls | Wall Field の method / topology option |

## rejected UX

- 旧 Generate panel をそのまま Build graph に埋める。
- adjacency の設定が、どの input 型を読むか分からない。
- ルール text が変更されても Generate 結果に差が出ない。

