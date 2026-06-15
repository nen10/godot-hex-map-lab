# DESIGN-10 UX

## 対象 user

dock を開いたゲーム開発者（まず戦術/ダンジョン系）。

## タブごとに達成したい「最初の体験」（experiential 意図）

| tab | 開いた瞬間に分かること | 触りたくなるもの |
|---|---|---|
| Build | 「ここで map の生成方式を組む」。graph canvas が主役 | `[Generate]` / node を置く |
| Paint | 「ここで手編集して仕上げる」。brush と対象 layer が見える | brush を選んで viewport を塗る |
| Export | 「ここで Godot へ渡す」。渡し方が card で選べる | 目的の card（Runtime Resource / Scene / Graph） |
| Catalog | 「使える tile/object の一覧」。視覚 board | entry card / 追加 |
| Layers | 「どの role がどう積まれているか」。stack 視覚 | role の visible/lock/writable |
| Resources | 「この map の資産棚」。足りないものが分かる | `[Create Missing Resources]` |

## 避ける体験（前回失敗の是正）

- 先頭に `Readiness Summary` / `Next actions:` / `Shared resources:` のラベル列（U1/U6）。
- 「No Level Document. / Tile Catalog: Not selected. …」の未設定ラベル列（empty は CTA に）。
- 内部語彙（型説明・source badge 解説・debug flag）を主面に出すこと（tooltip/debug drawer へ）。

## UX Candidate Matrix（画面意図の確定）

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 各タブ先頭 | A: work surface / B: context+resource row | **A** | LAYOUT_SKETCH_POLICY §3-1 |
| empty 表現 | A: 行動 CTA / B: 状態ラベル列 | **A** | §3-4 |
| map semantics 表示 | A: context chips / B: 詳細 row | **A** | §3-3 / §3-6 |
| primary action | A: 1つ目立たせる / B: 並列ボタン群 | **A** | §3-2 |
