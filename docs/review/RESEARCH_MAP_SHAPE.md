
## 概念検証: 壁の対称生成とデータ管理用マップ形状について

### 簡単な実験

`./tools/debug_generated_map.sh`

### 可能な実装に関する検討

    1. マップの形状変換は core APIに含めない。壁の対称生成の結果に関する整形のための内部処理を目的とする

    2. 壁の生成方式については
      - simple / 任意の N
      - 対称生成( Hex-inward Markov mesh model ) / radius
      の2方式を用意する。

    3. 対称生成の結果は
      - toricなマップの場合、対称生成後にループを扱いやすい正方形に変換した形状(9-split付き)のみをサポートする。
      - non-toricなマップの場合、
        - 正方形 : toricと同様の方法で正方形に変換したもの
        - 正六角形 : 正方形変換後、9-split領域の端二つを丸ごと削除することで得られる六角形
        の 2形状をサポートする。toricな処理は以後扱わず、9-splitを保持する必要はない。

    4. toricな処理の扱いについて
      - ∞マップ : ループ周期Nで逐次的にマップを展開することによって、サイズ無限大のマップを表現する
      - トーラスマップ : 実際にサイズNのトーラスを表現する
      の2方式をサポートする。
      入り口としては、
      -  [ 四角形 / 正六角形 / ∞平面 / トーラス平面 ]
      - サイズ・ループ周期 N の指定
        - 四角形 : 生成方式選択可能/サイズ N を選択,長方形生成ならサイズN1,N2を選択
        - 正六角形 : 生成方式選択可能/ サイズ N を選択
        - ∞平面 : 生成方式選択可能/ ループ周期 N を選択 / toric正方形を保持
        - トーラス平面 : 生成方式選択可能/ ループ周期 N を選択 / toric正方形を保持

### 2026-05-21: Generation Radius 3倍数の見た目調査

再現条件:

- `Generator = Hex-inward Markov mesh model`
- `seed = 888`
- `Wall Prob = 1.0`
- `Restore Connectivity = true`
- `Generation Radius = 3` を主対象にし、`6` / `9` も同じ傾向を確認



headless 調査結果:

| radius | shape | cells | walls | floors | connected |
|---:|---|---:|---:|---:|---|
| 3 | square | 49 | 18 | 31 | true |
| 3 | torus | 49 | 22 | 27 | true |
| 3 | hex | 37 | 12 | 25 | true |
| 6 | square | 169 | 69 | 100 | true |
| 6 | torus | 169 | 73 | 96 | true |
| 6 | hex | 127 | 48 | 79 | true |
| 9 | square | 361 | 149 | 212 | true |
| 9 | torus | 361 | 156 | 205 | true |
| 9 | hex | 271 | 106 | 165 | true |

切り分け:

- `ensure_connected=false` でも raw floor は多い。`wall_probability=1.0` が全 cell wall を意味するのは radius 1 / 2 の direct generation だけで、radius 3 以上の対称生成は distribution 参照で floor を残す。
- `ensure_connected=true` では raw wall がさらに削られる。radius 3 の square は `23 -> 18`、torus は `23 -> 22`、hex は `15 -> 12` へ変化した。
- torus は cyclic path を使えるため、同じ raw wall set でも non-toric square より wall 削除が少ない。
- hex は split 0 / 7 を除外するため、phase2 の outer_mod / outer_wave が出力形状から消え、square / torus と分布が変わる。
- phase2 は radius 3 / 6 / 9 すべてで `phase2_groups=5`、`outer_mod entries=12`。border は moved reference を含む。

原因候補:

- max wall + connectivity restoration の組み合わせで、連結化のための削除経路が直線的に目立つ。
- protected floor の `HexVector.zero()` は split 8 の中心 cell ではないため、見た目の中心からではない連結経路が作られる。
- `symmetry_generation_tags()` は全 cell を網羅しない診断 tag で、radius 3 / 6 / 9 に未タグ cell が残る。アルゴリズム修正判断には生成処理そのものの trace 追加が必要。

異常判定の基準が決まった後、生成処理そのものの trace と期待分布を使って修正範囲を決める。

(*) 本来期待していた条件:
dist id  -> 888
任意seed
他generate radiusとの比較
