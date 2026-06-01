# HEX_CELL_BUTTON_EDITOR_UI_PLAN_REVIEW_2026-05-31.md

この文章はagentによる計画文書レビューです。

## 対象

- `docs/plan/HEX_CELL_BUTTON_EDITOR_UI_POLICY_2026-05-31.md`
- `docs/plan/HEX_CELL_BUTTON_EDITOR_UI_IMPLEMENTATION_PLAN_2026-05-31.md`

## レビュー観点

- 既存矩形control buttonではなく、六角形cell buttonを正としている。
- `hex_dist_editor.gd` の六角形cell配置を価値として再利用する計画になっている。
- flat-top / pointy-top、近傍shape、Editor UI用サイズ指定を入力にして配置情報を作れる。
- Query Row offsetがこのUI管理機能の利用例として計画されている。
- 公式Godot documentation確認が方針に反映されている。
- 方針文書に比較事項、未確定事項、破壊的変更候補、fallback扱いがある。
- 詳細実装計画に対象ファイル、入出力、API、resource schema、テスト計画、実装手順、完了判定がある。
- 詳細実装計画で見つかった未確定事項が方針文書へescalationされている。

## Findings

### Finding-01: 矩形hitを避ける根拠が必要

Severity: High

ユーザー要望は既存矩形control buttonではなく六角形cell buttonとして実装すること。初稿で単一custom Controlを採用していたが、なぜGodot標準 `Button` を採用しないかを明確にする必要があった。

対応:

- 方針文書に、標準 `Button` / cellごとのcustom `Control` / 単一custom `Control` / texture系の比較を追加した。
- 単一custom `Control` で全polygonをhit testする案を代表案にした。
- 矩形button、矩形hit、text-only direction gridをfallbackとして明示した。

### Finding-02: 公式documentation確認が計画に結びついていない

Severity: Medium

公式docs確認自体は実施したが、初稿の計画では「どの公式情報を何に使うか」が弱かった。

対応:

- 方針文書に公式ドキュメント確認セクションを追加した。
- Custom GUI controlsの `_get_minimum_size()` / `_gui_input()`、CanvasItemのpolygon描画、Geometry2Dのpolygon hit test、Controlの `update_minimum_size()`、BaseButtonのbutton状態を計画へ反映した。

### Finding-03: `cell_gap` の解釈が詳細計画だけに出ていた

Severity: Medium

詳細実装計画では `HexMapTileAdapter.hex_to_local(cell, cell_radius + cell_gap, flat_top)` を使うとしていたが、これは「辺間gap」ではなくpitch補正である。この比較事項は方針へ上げる必要がある。

対応:

- 方針文書に `cell_gap` の解釈候補を追加した。
- 代表案ではpitch補正値として扱うと明記した。

### Finding-04: label描画方式の未確定事項が詳細計画に残っていた

Severity: Low

詳細実装計画に `draw_string()` かtooltip中心かという未確定事項が残っていた。詳細計画内で未確定事項を検討した場合は方針へescalationする必要がある。

対応:

- 方針文書にlabel描画方式の候補を追加した。
- 代表案をPanel自身の短い `draw_string()` label、長文はtooltipとした。
- 詳細実装計画から未確定表現を削除した。

### Finding-05: `hex_dist_editor.gd` の既存配置との対応が曖昧

Severity: Medium

`hex_dist_editor.gd` の価値は既存の六角形配置にあるため、custom shapeへ移行するだけでは不足。既存の上側3近傍がどのdirection indexに対応するかを固定する必要がある。

対応:

- 方針文書に、`distribution_pattern` は上側3近傍 direction index `[3, 2, 1]` として扱うことを追加した。
- 詳細実装計画に `n_neighbor == 3/2/1` のdirection indexを明記した。

## 確認結果

- 新規の方針文書と詳細実装計画がある。
- 既存Query Row offset専用計画とは別目標として、hex cell button UI管理機能を正にしている。
- 公式Godot documentation確認が文書に記録されている。
- 破壊的変更候補とfallback扱いが明示されている。
- flat-top / pointy-top、近傍shape、cell radius / gap / paddingを入力とするlayout builder計画がある。
- Query Row offsetと `hex_dist_editor.gd` の両方への統合計画がある。
- テスト計画はlayout builder、panel hit test、Query Row、Distribution Editorを含む。
- 実装変更は行っていない。

## 残リスク

- `draw_string()` のfont取得と縦中央揃えは実装時にGodot theme / font APIの確認が必要。
- keyboard focus navigationはcustom Control内の状態管理になるため、初期実装ではmouse操作の完成を先に固定してもよい。
- `cell_gap` をpitch補正として扱うため、UI上の「Gap」表記が実寸の辺間距離だと誤解される場合は、labelを `Pitch Gap` にする余地がある。
