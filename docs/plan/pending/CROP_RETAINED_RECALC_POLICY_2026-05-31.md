# CROP_RETAINED_RECALC_POLICY_2026-05-31.md

## 目的

Mask Crop確認中にShape / Size / Mask Query Rowを編集しても、Crop状態を保持し、Crop resultを再計算するモードを追加する。

現在の「編集するとCrop Offへ戻す」挙動は安全側のfallbackとして成立しているが、Crop結果を見ながら条件を微調整する操作には向かない。

## 現状

- `Crop` checkboxがOnのとき、Apply / Save はCrop result dataを対象にする。
- Mask Query RowやShape / Size編集時、`_reset_mask_crop_if_enabled()` によりCrop Offへ戻る。
- Reference Query RowやDeductor Floor Source編集ではCrop Offに戻らない。
- Crop countは `_overlay_crop_result_data()` から非`Any` itemのunion countを計算する。

## 方針

代表案として、Crop checkboxを単純なOn/Offから「Crop Preview mode」として扱い、Mask queryまたはShape universeの変更時にCrop resultを即時再計算する。

実装上は最初に `Crop Auto Refresh` checkboxを追加し、既存挙動と新挙動を比較可能にする。ユーザー操作として十分なら、破壊的にAuto Refreshを標準動作へ寄せ、従来のreset経路を削除する。

## 比較事項

### 候補A: Crop On中の編集は常に再計算する

- 操作は単純。
- query sourceが大きい場合、編集のたびに評価コストが発生する。
- 結果が常に最新になるため、Crop previewとして一貫する。

最終形の候補。

### 候補B: `Crop Auto Refresh` checkboxで切り替える

- 既存挙動と比較しやすい。
- UI項目が増える。
- 導入段階の代表案。

採用候補。

### 候補C: `Refresh Crop` buttonを追加する

- 自動評価を避けられる。
- Crop保持の目的に対して操作が増える。

大量source向けの補助案として残す。

## 破壊的変更候補

- `_reset_mask_crop_if_enabled()` を廃止し、Mask / Shape編集時は `_refresh_mask_crop_count()` と表示更新へ置き換える。
- `Crop` checkboxを `Crop Preview` toggleへrenameする。
- Apply / Save buttonsの処理を、Crop stateではなく明示的な `crop_preview_data` cacheへ接続する。

## Fallback扱い

編集時にCrop Offへ戻す現状はfallbackとして扱う。仕様の中心は「Crop Onなら表示中のCrop resultは現在のMask queryとShape universeから再計算されたもの」とする。

再計算に失敗した場合に古いCrop resultを使い続ける動作は避ける。失敗時はCrop statusをerrorにし、Apply / Saveを止める。

## 入出力

入力:

- Mask Query Rows
- Shape / Size controls
- Source Registry entries
- Crop Preview mode
- Crop Auto Refresh mode

出力:

- current crop universe
- `HexOverlayData` crop result
- crop count / status text
- Apply / Save対象resource

## テスト方針

- Crop Auto Refresh OnでMask Query Row編集後もCropがOnのまま結果が更新される。
- Shape / Size変更後もCropがOnのままuniverseとcountが更新される。
- Auto Refresh Offでは既存のCrop Off resetが維持される。
- 空結果時はGenerate / Apply / Saveの可否が明確になる。

## 完了条件

- Crop保持再計算の状態遷移がテストで固定される。
- Crop result dataは常に現在のquery / universeと一致する。
- fallbackとしてのCrop reset経路がUI上で区別されるか、破壊的に削除される。
