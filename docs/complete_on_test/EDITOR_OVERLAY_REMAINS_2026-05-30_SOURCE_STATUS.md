# EDITOR_OVERLAY_REMAINS Source Registry / Stack Status 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 3. Source Registry 可視化と操作フィードバック、4. Crop Off Source Stack の状態表示を実装済みとして扱う。

## 入出力

### Source Registry Details

入力:

- Source Registry entries
- `HexMapData` / `HexOverlayData`
- resource path

出力:

- source row header
  - `display_name [resource_type]`
- source details
  - `Path: resource_path`
  - `ItemKey: cell_count`
- Source Registry status
  - source件数
  - empty state

`HexMapResource` sourceは `Any` / `Floor` / `Wall` のcell数を表示する。`HexOverlayResource` sourceは保存済みitemごとのcell数を表示する。

### Crop Off Source Stack Status

入力:

- Source Registry内のOverlay source
- `Apply Write`
- `Existing Item`

出力:

- stack resultを反映した `_current_overlay_data`
- Source Registry status
  - stack対象Overlay source数
  - current overlayのitem数
  - occupied cell数
  - write policy
  - existing item policy

Overlay sourceが0件の場合、Apply / Save / current更新は行わず、Source Registry statusに理由を表示する。

## 実装状況

- [x] Source Registry source rowにresource pathとitem別cell数を表示する
- [x] Source Registry statusにsource件数とempty stateを表示する
- [x] Crop Off / Overlay stack実行後にsource数、item数、occupied数、policyを表示する
- [x] Overlay sourceが0件の場合にUI statusで理由を表示し、current overlayを更新しない

## テスト

- `tests/test_editor_plugin.gd`
  - Overlay source detailsに保存済みitem cell数とresource pathが表示される
  - Primary source detailsに `Any` / `Floor` / `Wall` のcell数が表示される
  - Source Clear後にsource件数とempty stateがstatusに表示される
  - Crop Off source stack後にsource数、occupied数、write policyがstatusに表示される
  - Overlay sourceが0件の場合にstatusで理由が表示され、stackが失敗する

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
