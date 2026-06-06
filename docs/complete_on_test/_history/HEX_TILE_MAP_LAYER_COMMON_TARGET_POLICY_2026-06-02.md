# HEX_TILE_MAP_LAYER_COMMON_TARGET_POLICY_2026-06-02.md

## 目標 UX

- `docs/complete_on_test/HEX_TILE_MAP_LAYER_COMMON_TARGET_UX_2026-06-02.md`

## 採用候補

### 候補A: `HexTileMapLayer extends TileMapLayer` へ作り直す

不採用。

理由:

- Godot の `TileMapLayer` は標準 TileMap editor の対象になるため、Scene Tree で選択した時に addon manual edit と atlas paint が再び競合しやすい。
- 現行 `HexTileMapLayer` は internal base layer / loop copy layer / runtime input / hit dictionary を持つ wrapper API として育っている。継承変更は既存 runtime helper と loop display の互換性を大きく壊す。
- 公式 docs の `Node.add_child(..., internal)` は internal child を通常の `get_children()` から隠す用途として説明しており、wrapper node が内部表示 layer を隠す設計と相性がよい。

### 候補B: `Node2D` wrapper を維持し、内部 `TileMapLayer` を表示実装として正規化する

採用。

内容:

- `HexTileMapLayer` は addon が選択・編集する scene node として扱う。
- 内部 `TileMapLayer` は tile rendering 用の実装 detail とする。
- `hex_map` resource 適用時に、表示可能な `TileSet` / atlas source / floor tile / wall tile が未設定なら sample atlas を自動設定する。
- `HexTileMapLayer` に display TileSet を明示的に設定する public helper を追加し、生成 Dock から利用する。

### 候補C: 生成 Dock の Target を `TileMapLayer` 専用のままにする

不採用。

理由:

- Manual edit 側だけ `HexTileMapLayer` を推奨しても、生成直後の表示 target と手動編集 target が分かれる。
- UX 説明が「生成は `TileMapLayer`、編集は `HexTileMapLayer`」になり、`INTER_SCALE_POLICY.md` の UI 層で型使い分けを減らす方針に反する。

### 候補D: 生成 Dock の primary target に `HexTileMapLayer` を追加する

採用。

内容:

- Target list は scene root 以下の `HexTileMapLayer` と plain `TileMapLayer` を収集する。
- `Add new layer...` は `HexTileMapLayer` を作成する。
- Primary apply は `HexMapResource.from_map_data()` を `HexTileMapLayer.hex_map` に設定し、floor / wall display tile 設定を同期する。
- plain `TileMapLayer` への primary apply は互換経路として維持する。

## 破壊的変更

- 生成 Dock の `Add new layer...` は plain `TileMapLayer` ではなく `HexTileMapLayer` を作る。
- `HexTileMapLayer` は display TileSet 未設定時に sample atlas source を自動作成する。空 TileSet のまま非表示にする挙動は維持しない。
- `Hex Map Edit` が `HexTileMapLayer` target に apply するときは、表示だけでなく `hex_map` property も更新する。

## fallback 扱い

- plain `TileMapLayer` target は既存 scene / overlay / legacy 操作の互換 fallback とする。
- Overlay apply は現段階では plain `TileMapLayer` を正とする。`HexTileMapLayer` に overlay layer を持たせる場合は別計画で扱う。

## UX escalation

実装中に次が判明した場合は UX 文書へ戻す。

- `HexTileMapLayer` の自動 sample atlas が、ユーザー指定 TileSet を上書きする条件が広すぎる場合。
- Target list の class 表示が Dock 幅を圧迫し、plain / Hex の識別より操作性を悪化させる場合。
- Overlay Generation でも `HexTileMapLayer` を正規 target にする必要が出た場合。
