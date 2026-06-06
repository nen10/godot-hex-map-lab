# QUERY_ROW_OFFSET_GRAPHICAL_CONTROL_POLICY_2026-05-31.md

## 目的

Query Rowのoffset操作を、Mask / Reference / Deductor Floor Sourceに閉じた個別実装から、再利用可能なhex方向操作controlへ分離する。

既存の3列button gridは機能しているが、今後のmanual editing、runtime debug、query以外の座標操作にも使える部品として扱う。

## 現状

- `hex_map_gen_dock.gd` が `_build_query_direction_control()` で `GridContainer` を直接組み立てている。
- 各query rowは `direction_buttons` と `direction_control` を辞書に保持する。
- button sizeはDock全体の `_query_direction_button_size` と3つのSpinBoxで同期している。
- 表示は `+Q` / `-R` / `+S` / `-Q` / `+R` / `-S` のtext buttonである。

## 方針

代表案として、Editor向けの専用Control `HexDirectionOffsetControl` を追加する。

このControlは、offset値、button size、flat-top / pointy-top表示、hex方向buttonのsignalを内部に持つ。Query RowはControlから `offset_changed(offset)` を受け取り、row辞書の `offset` とlabelを更新する。

## 比較事項

### 候補A: 既存GridContainerをhelper化する

- 変更量が少ない。
- text buttonのままなので、query以外で使う場合の視認性改善は限定的。

代表案にはしない。

### 候補B: `Control`派生でhex cell風button配置を描画する

- 視覚的に方向関係が分かりやすい。
- `hex_dist_editor.gd` の描画ノウハウを使える。
- buttonとしてのfocus / tooltip / disabled状態を自前管理する必要がある。
- 初期実装では標準Buttonの矩形hitを使い、hex形状は配置と補助描画で表現する案がある。

採用候補。

### 候補C: `.tscn` sceneとしてUI部品化する

- Godot Editor上で配置を調整しやすい。
- addon配布時にscene dependencyが増える。

最初の実装ではGDScript Controlとして扱い、必要になったらscene化する。

## 破壊的変更候補

- Query Row辞書から `direction_buttons` / `direction_control` の直接保持を廃止し、`offset_control` だけを保持する。
- `+Q` などのtext labelを常時表示せず、tooltipまたは小さなdirection markerへ移す。
- direction button size SpinBoxをMask / Reference / Deductorごとに見せるのではなく、共通設定として1箇所にまとめる。

## Fallback扱い

既存の3列text button gridは、移行中のfallback UIとして扱う。Query Row offset操作の仕様根拠は、`HexDirectionOffsetControl` の入力offsetと `offset_changed` outputに置く。

hex形状の正確なhit testを持たない初期実装は、操作性検証用の段階的実装として扱う。正確なhex hitが必要になった場合は、同じControl APIのまま内部入力判定を差し替える。

## 入出力

入力:

- current offset: `HexVector`
- direction index: `0..5`
- orientation: flat-top / pointy-top
- button size
- enabled / disabled

出力:

- updated offset: `HexVector`
- `offset_changed(offset)` signal
- optional `direction_pressed(direction_index, offset)` signal

## UI仕様

- 中央に現在offsetを表示する。
- 周囲6方向にbuttonを置く。
- flat-top / pointy-topで視覚配置を切り替える。
- buttonにはtooltipで `+Q` 等のbasis名を出す。
- keyboard focus可能なbuttonを使い、Editor Dockで操作しやすくする。

## テスト方針

- Control単体で6方向buttonがoffsetを更新することを検証する。
- Query RowがControlのsignalを受けてrow offsetを更新することを検証する。
- button size変更が既存rowと新規rowへ反映されることを検証する。
- Mask Query Row編集時のCrop連動は既存仕様に従う。

## 完了条件

- Query Rowのoffset操作が専用Control経由になる。
- Mask / Reference / Deductor Floor Sourceで同じControlを使う。
- `docs/TEST.md` のQuery Row offset control概要が新部品名を含む。
