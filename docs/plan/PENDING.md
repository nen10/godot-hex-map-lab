
### マップのマニュアル編集機能

分類: 2. MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY。

理由:

- manual edit 用表示では、RUNTIME_INTERACTION_LOOP_PATH の実装結果を生かし、loop duplicate を tile として視認しながら編集できる必要がある。
- outline-only duplicate 表示は fallback として扱い、目的の一貫性を優先して runtime-owned loop copy 表示へ進める。

テスト可能な分割仕様:

- 入力:
  - selected `HexMapDocumentResource`
  - selected editable `HexTileMapLayer`
  - edit mode: shape / wall-floor / floor tile / wall tile / object / label
  - loop display mode / rect / margin
  - hit dictionary: canonical `hex` + displayed `visual_hex`
  - tile paint payload: source id + atlas coords + alternative tile
  - object payload: object id + object property dictionary
  - label payload: label id + label text
- 出力:
  - updated `HexMapDocumentResource`
  - updated `HexTileMapLayer`
  - loop copy display refresh
  - undoable editor command
  - edited canonical cell status
  - selected visual representative status
- headless test:
  - visual duplicate click が canonical document cell を更新する
  - loop copy display が wall / floor edit 後に更新される
  - Undo / Redo が document と loop duplicate 表示の両方を戻す
  - edit mode ごとに必要な payload controls だけが表示される
- editor workflow test:
  - `HexTileMapLayer` target で loop display を有効にし、duplicate tile を click して canonical cell を編集できる
  - 保存した `.tres` を再読み込みして canonical document の編集状態を復元できる

関連計画:

- `docs/plan/RUNTIME_INTERACTION_LOOP_DISPLAY_TILE_COPY_IMPLEMENTATION_PLAN_2026-05-31.md`
- `docs/plan/MANUAL_MAP_EDITING_TOOL_LOOP_DISPLAY_IMPLEMENTATION_PLAN_2026-05-31.md`

### 4. CROP_RETAINED_RECALC

Mask Crop On中にquery / shape / sourceを変更した場合の再計算モードを実装する。

`docs/plan/CROP_RETAINED_RECALC_POLICY_2026-05-31.md`
`docs/plan/CROP_RETAINED_RECALC_IMPLEMENTATION_PLAN_2026-05-31.md`

### 5. PUBLIC_SAMPLE_API_PACKAGE

公開用 sample project、API reference、package生成を整備する。

`docs/plan/PUBLIC_SAMPLE_API_PACKAGE_POLICY_2026-05-31.md`
`docs/plan/PUBLIC_SAMPLE_API_PACKAGE_IMPLEMENTATION_PLAN_2026-05-31.md`
