# Multi Layer Overlay Deductor Connectivity 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Markov Mesh Overlay generation で生成itemを通行阻害itemとして削除し、指定floor集合の連結性を回復する Deductor を実装済みとして扱う。

## 入出力

入力:

- `HexOverlayData`
- item key
- floor cells
- connect method
  - `CONNECT_DENSE`
  - `CONNECT_SPARSE`
  - `CONNECT_NONE`
- seed

出力:

- 削除された item cells
- 更新された `HexOverlayData`

## 実装状況

- [x] `HexMapGenerator.deduct_items_for_connectivity()` を追加する
- [x] overlay item cells を `HexMapData` の walls として扱い、既存の connectivity restore を再利用する
- [x] 削除された walls 相当のcellを overlay item cells から取り除く
- [x] Editor Dock の Markov Mesh Overlay generation は Adjacency Reference Off の場合に Deductor を適用する
- [x] `CONNECT_NONE` では item を削除しない

## テスト

- `tests/test_hex_map_generation.gd`
  - 3 cell line の中央 item がfloor連結を塞ぐ場合、Deductor が中央itemを削除すること
  - Deductor 後に `HexOverlayData` の item cells が更新されること
