# Core API 実装計画

## 計画中の項目

Editor Dock の progressbar / cancel に接続できるよう、Core の壁生成 API に割り込み可能な呼び出しを追加する。
既存の shape 生成 API は戻り値 `HexMapData` を維持しつつ、任意の `interrupt_options` を受け取った場合だけ progress / cancel 分岐を実行する。-> 済み
実行時間が長くなる連結性回復用の関数(`HexMapGenerator.restore_connectivity_sparse()`, `HexMapGenerator.restore_connectivity_dense()`)においても progress / cancel 分岐を実行できるようにしたい。アルゴリズムの実行速度を損なわないように注意する。

## 追加 API

...

## 密度別テスト

`tests/test_hex_map_generation.gd` で検証する。


## 完了条件

- `tools/test.sh` が通る。
- `docs/TEST.md` に追加テスト範囲を記録する。
