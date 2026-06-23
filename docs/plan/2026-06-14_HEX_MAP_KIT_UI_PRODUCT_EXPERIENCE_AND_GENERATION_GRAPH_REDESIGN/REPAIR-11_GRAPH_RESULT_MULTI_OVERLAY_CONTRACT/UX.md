# REPAIR-11 UX

## user goal

ユーザーは、複数の item / overlay 生成を graph 上で組み合わせ、`Generate` 後に viewport と layer/document 上で何が最終結果に含まれたかを確認したい。

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. overlay は最後の1つだけ採用 | low | high | low | reject | どの overlay が捨てられたか分からない。 |
| B. Result に複数 overlay を暗黙接続 | medium | high | medium | reject | 順序と衝突が見えない。 |
| C. Result に明示 overlay slot を追加 | high | medium | medium | adopt | 入力一覧と順序を UI / test で証明できる。 |
| D. Compose node で合成してから Result | medium | high | high | reject | Compose と Result の責務が重なる。 |

## expected experience

1. ユーザーは `Shape` などで terrain を作る。
2. 複数の `Item Generator` または `Source Overlay` を作る。
3. `Result` に terrain と overlay slot を接続する。
4. `Result` inspector に overlay 一覧が見える。
5. `Generate` で terrain と全 overlay が viewport に出る。
6. `Apply` で各 overlay が別 generated overlay layer として保持される。
7. `Revert` で terrain と overlay が一緒に戻る。

## Result inspector

最低限表示する情報:

| 表示 | 意味 |
|---|---|
| terrain input | Result の主 terrain |
| overlay inputs | 接続済み overlay 一覧 |
| overlay order | 合成順序 |
| conflicts | 同一 item key / cell 衝突 |
| projection status | viewport に投影済みか |

## rejected UX

- `Result` が `result` を受け取る flow。
- `Compose` を primary row に置く flow。
- overlay が1つだけに折りたたまれる flow。
- graph cache summary だけで成功に見える flow。

