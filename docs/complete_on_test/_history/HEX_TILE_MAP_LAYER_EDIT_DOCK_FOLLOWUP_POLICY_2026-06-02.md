# HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_POLICY_2026-06-02.md

## 目標 UX

- `docs/complete_on_test/HEX_TILE_MAP_LAYER_EDIT_DOCK_FOLLOWUP_UX_2026-06-02.md`

## 採用候補

### 候補A: Last Edit traceだけを強化する

不採用。

理由:

- ユーザー要望は viewport表示の変化と明示設定項目を含む。
- traceだけでは Floor Tile / Wall Tile の表示反映不足を解消できない。

### 候補B: `HexTileMapLayer` に document payload display apply を追加する

採用。

内容:

- `HexMapDocumentResource.tile_overrides` を `HexTileMapLayer` の内部 display layer へ反映する。
- Floor / Wall default tile と tile override を同じ描画経路で扱う。
- Last Edit の display check は base tileだけでなく override後の display state を読む。

### 候補C: Object / Label は document保存だけでよい

不採用。

理由:

- 任意 Edit Mode で click 成功が viewportまたはtraceで分かる必要がある。
- object / label は atlas tileの変化ではないため、最低限 marker / label / highlight などの visual feedbackを設ける。

### 候補D: Object / Label は `HexTileMapLayer` の overlay draw で表示する

採用。

内容:

- Object は小さな marker / icon surrogate を cell上に描く。
- Label は textまたはlabel markerを cell上に描く。
- 初期実装では dataの有無が見えることを優先し、object database iconや高度なstyleは別計画に分ける。

### 候補E: Default tile settings を generation dock と共有する

部分採用。

内容:

- edit dock に Default Floor / Wall tile settings を置く。
- generation dock の設定値を直接共有する singleton state にはしない。
- Target から読み取る / Targetへ適用する操作で明示同期する。

### 候補F: edit dock Auto は cached target を優先する

不採用。

理由:

- `Auto: Selected / first scene layer` という label と実挙動が一致しない。
- explicit target selection と Auto の責務が混ざる。

### 候補G: edit dock Auto は live selection / first target を解決する

採用。

内容:

- Auto時は Editor selection の `HexTileMapLayer` / `TileMapLayer` を第一候補にする。
- Selectionに該当targetがない場合、scan root 以下の最初の target を使う。
- Explicit target時だけ Scene Tree selection sync を行う。

## 破壊的変更

- Edit Dock の UI layout を `ScrollContainer` root に変更する。
- Target Auto の解決順序を stale `_target_layer` 優先から live selection / first target 優先に変える。
- Last Edit の文言を拡張し、既存の短い `target=yes/no display=yes/no` 表示だけに依存しない。

## fallback 扱い

- plain `TileMapLayer` は互換 target として維持する。
- Object / Label の最初の viewport表示は marker / label surrogate とし、final art asset や database-driven icon 表示は仕様根拠にしない。
- atlas sourceが target TileSet に存在しない場合、設定不足として trace に出し、自動読み込みを正規成功条件にしない。

## UX escalation

実装中に次が判明した場合は UX 文書へ戻す。

- Object / Label marker が existing highlight / path / loop display と視覚的に競合する場合。
- Default tile settings の項目数が Dock を圧迫し、section折りたたみが必要になる場合。
- Plain `TileMapLayer` で Auto target を維持する価値が低く、明示 targetだけにした方が安全な場合。
