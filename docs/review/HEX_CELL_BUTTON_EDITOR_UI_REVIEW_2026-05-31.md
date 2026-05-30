# HEX_CELL_BUTTON_EDITOR_UI 実装レビュー (2026-05-31)

この文章はagentによるレビューです。

## 対象

`docs/plan/HEX_CELL_BUTTON_EDITOR_UI_POLICY_2026-05-31.md` および `docs/plan/HEX_CELL_BUTTON_EDITOR_UI_IMPLEMENTATION_PLAN_2026-05-31.md` の要件に対する staged 変更。

## 総評

`HexCellButtonLayout`（純粋 layout builder）と `HexCellButtonPanel`（custom Control）の2点が追加され、Query Row offset control が矩形 Button grid から hex polygon ベースの操作へ完全移行した。`hex_dist_editor.gd` の pattern 描画も共通 layout entry を使うようになり、polygon と hit test の単一 source of truth が確立されている。

全計画手順(1〜10)が完了し、全6テストファイルがパス。新規テスト19件（layout 5件、panel 4件、distribution 2件、query row 8件間接的）。

---

## 当初の要件より優れている実装

### 1. Keyboard focus navigation の実装
実装計画では keyboard 操作は「入れる場合」のオプション扱いだったが、実装は `_handle_key()` + `_move_focus()` + `cell_focus_changed` signal を備え、方向キーによる pressable entry 間の循環移動と Enter/Space による pressed emit に対応している。候補 A（標準 Button）以外の方式で焦点移動を自前実装する難度を考慮すると、初期実装としては十二分。

### 2. `_distribution_pattern_entries` の分離
`_draw_pattern()` に埋め込まれていた `ref0`/`ref1`/`ref2` の固定 Vector2 が、`_distribution_pattern_entries(n_neighbor, origin)` + `_shift_pattern_entries_to_origin(entries, origin)` の2段に分離された。layout entry 生成（shape_cells + metadata）と origin 調整が分かれ、再利用性が高い。

### 3. `_draw_hex_entry` の polygon 再利用
旧 `_draw_hex(control, center, fill)` が消え、`_draw_hex_entry(control, entry, fill)` が entry の polygon を直接使う。描画の「形」が layout builder と完全に共有され、position の不一致バグが原理的に起きなくなった。

### 4. `_apply_query_direction_button_size` の除去
旧実装は GridContainer 内の全 Button と placeholder Control に `custom_minimum_size` を設定する走査ループを持っていたが、`HexCellButtonPanel.configure()` の `cell_radius`/`cell_gap`/`padding` 更新に集約された。row ごとに個別のサイズ設定を持つ複雑さが解消されている。

### 5. Orientation 変更時の offset panel 自動更新
`_on_tile_orientation_changed` が `_refresh_all_query_offset_panels()` を呼び、flat-top / pointy-top 切替時にすべての Query Row の hex cell 配置が即時再計算される。

---

## 要件に対する実装の不足

### 1. `show_labels` プロパティが未使用

`HexCellButtonPanel` は `@export var show_labels: bool = false` を持ち `configure()` でも値を受け取るが、`_draw()` 内で `draw_string()` を呼んでおらず、いかなる label 描画も行わない。destroy plan では「labelはPanel自身が `draw_string()` で描く」が取り消し線になっているため現状の動作は仕様に沿っているが、プロパティ自体が dead code になっている。

#### ユーザーの動作確認・意見

使うケースがないとは言えない。

### 2. `_on_query_row_direction_pressed` が dead code

`_build_query_offset_control` が GridContainer + text Button を廃止し `HexCellButtonPanel` に置き換えた結果、旧 direction button の pressed ハンドラ `_on_query_row_direction_pressed` に接続する経路が存在しない。テストでもこの関数は呼ばれていない。残しても構文的に問題はないが、confidence を下げる。

### 3. Distribution Editor の `_pattern_controls` 配列への `draw` signal 接続が layout 移行前のまま

`_test_distribution_editor_pattern_redraw_uses_layout_entries` は `control.draw.is_connected(Callable(editor, "_draw_pattern").bind(3, 0, control))` を確認しているが、実装本体（`hex_dist_editor.gd` の `_draw_pattern`）は内部で `_distribution_pattern_entries` → `_draw_hex_entry` を使うようになったため、draw signal の接続先は同じだが内部実装が共通化されている。テストの assertion 文言は「draw through the layout-backed draw method」と正しく表現されている。

---

## UI 上の改善点

### 1. `Cell Radius` / `Gap` / `Padding` のラベル長

3つの SpinBox が横一列に並び、各ラベルが "Cell Radius" / "Gap" / "Padding" と長い。Dock の横幅が狭い環境では折り返しや省略が発生する可能性がある。"Radius" / "Gap" / "Pad" への短縮を検討。

#### ユーザーの動作確認・意見

- 横に長いことは問題ではない
- このコントロールRow自体は定数値でも構わない。
- hex cell panelを作成しようと思った時に、"Cell Radius" / "Gap" / "Padding"を含めて指定することができるAPIが存在することが重要である。
- このコントロールRowはEditorに対するメタな設定オプションとして配置場所を検討し、(それぞれ同じ値に連動するにせよ)一つにまとめる。特に、Dock内の下部にあるRowによって、上部のhex cell panelのサイズが変わることにより、Rowの位置が上下することでSpinを連続で押しにくくなるのを避けるため、上側の一つが適切な位置に配置されていれば十分だが、固定値によるhex cell panel作成でもよい。

### 2. offset label（`"0,0,0"`）が hex cell 外に残っている

offset の現在値表示は依然として Query Row 上の `Label` として hex cell panel の左に配置されている。hex cell panel の center cell には offset key（例: `"1,0,0"`）が label_by_cell で渡されているが、`show_labels=false` のため表示されない。label を hex cell 内に表示するか、外部 label を hex cell panel の近くに再配置する余地がある。

#### ユーザーの動作確認・意見

Query Row の全体的な構成を再検討したい。
- Up/Down としてSpinに似たような上下ボタンを使用したいです。できますか？
- Query Row 追加の際、ファイル単位でのResource名を選択し、Query Row 内部では[ Resource名 / ItemKey名 ] のコンボボックスに代わり Resource名のラベル / [ ItemKey名 ]のコンボボックス という形で選択のスコープを段階的に狭めたい。コンボボックス内容はスクロール可能にしたいです。できますか？
- Query Row 一段目のオッf背t表示ラベルの隣にhex cell panelを移動できますか？


### 3. center cell の視覚的ヒントがない

center cell（現在 offset を示す cell）は `_entry_fill()` で「非 pressable の色」として描画されるが、offset 表示であることを示す専用の色やマークがない。tooltip で "Current offset ..." が表示されるのはマウスホバー時のみ。

#### ユーザーの動作確認・意見

center cellにマウスホバーしても"Current offset ..."が表示されないので、何の話かよくわからない。


---

## 機能・コード上の改善点

### 1. `_query_direction_label` / `_query_direction_label_map` / `_query_direction_tooltip_map` / `_query_direction_metadata_map` の責任重複

offset panel の設定に必要な4つの map を Dock 側で個別に構築しているが、`direction_cells()` が返す cell 集合に対して1つの関数で全 map を生成する方が保守しやすい。例えば:

```gdscript
func _query_direction_spec(offset) -> Dictionary:
    return {
        "shape_kind": "directions",
        "flat_top": _tile_settings_flat_top(),
        "cell_radius": _query_hex_cell_radius,
        "cell_gap": _query_hex_cell_gap,
        "padding": Vector2(_query_hex_cell_padding, _query_hex_cell_padding),
        "center_cell": HexVector.zero(),
        "pressable_cells": ...,
        "label_by_cell": ...,
        "tooltip_by_cell": ...,
        "metadata_by_cell": ...,
    }
```

現在の実装では `_refresh_query_offset_panel` がこの spec を構築しているが、各 map 関数が `_query_direction_label` を個別に呼んでいる。

#### ユーザーの動作確認・意見

利点がわからないので十分に議論してから検討します

### 2. `_entry_fill` の色が Editor テーマ非依存

`Color(0.28, 0.44, 0.72, 0.95)` などのハードコードされた色が使われている。Godot Editor のダーク/ライトテーマ切替には追従しない。`get_theme_color()` を使う方式にするとテーマ互換性が上がるが、`hex_dist_editor.gd` の既存色（`WALL_FILL`/`FLOOR_FILL`）との整合を取る必要がある。


#### ユーザーの動作確認・意見

利点がわからないので十分に議論してから検討します


### 3. `_polygon_bounds` が `Rect2` 生成前に早期リターンしない

`if points.is_empty(): return Rect2()` があるが、`hex_polygon()` は常に6点を返すため、この分岐は事実上 dead code。layout builder の呼び出し側が空配列を渡す可能性を防御していると解釈できる。

### 4. `_generate_overlay_data_from_snapshot` の `_apply_write_policy` 参照

staged diff には含まれないが、Apply Write 統合後の Dock コード確認中に気づいた点: `_generate_overlay_data_from_snapshot` が `snapshot["apply_write_policy"]` を使うようになったため、snapshot の key 名変更が Dock 内部で一貫している。ただし、テストで `_generate_overlay_data_from_snapshot` を直接呼ぶ場合、snapshot dict に `apply_write_policy` が含まれていなくてもデフォルトで `CLEAR_AND_WRITE` が使われる。安全。

---

## 不明点

### 1. `cell_gap = 0` と `cell_gap > 0` の cell 接触/重なり

`cell_gap = 0` のとき、隣接する hex cell の polygon は辺を共有し、境界線上の point は両方の cell に hit する。`hit_entry` は後方優先（entries 配列の末尾優先）のため、決定論的な挙動にはなるが、ユーザーが境界線をクリックしたときの cell 選択は entry 順序に依存する。Query Row では pressable cells が directions のみで隣接せず、Distribution Editor では pressable がないため実害はない。将来、密に詰めた pressable cells（例: `disc` shape）を使う場合に注意が必要。

#### ユーザーの動作確認

Query Rowについて`cell_gap = 0` のとき重複するcell境界線をクリックすると両方のcellが反応し、vectorの二つの成分がincrementする。コード上は隣接しない配置に見えるかもしれないが、hex cellの集まりとしては隣接するものである。通常の動作であり重大な問題ではない。

### 2. `_set_generation_controls_disabled` が `_refresh_all_query_offset_panels` を呼ばない

Generation running 中に `_set_control_disabled(panel, true)` が `panel.enabled = false` を設定するが、panel の再描画は行われない。`enabled` プロパティ変更が `queue_redraw()` をトリガーしないため、disabled 状態の色変更が次回の redraw まで遅延する。実際には generation 中に panel を操作できないため視覚的な影響は小さいが、`_refresh_all_query_offset_panels()` 相当の再描画トリガーがあると確実。

#### ユーザーの動作確認

disabled 状態の色があるんですか？簡単なテストケースが不明。

---

## テストに対する評価

| 計画のテスト | 実装 | 状態 |
|-------------|------|------|
| layout: flat-top | ✅ | direction cells use tile adapter pitch |
| layout: pointy-top | ✅ | differs from flat-top |
| layout: minimum size padding | ✅ | grows with padding |
| layout: polygon hit rejects rect corner | ✅ | bounds corner rejected, center accepted |
| layout: custom/ring/disc shape hook | ✅ | custom returns duplicate, ring=6, disc=7 |
| panel: emits pressed for hex hit | ✅ | cell_pressed signal |
| panel: emits hover for hex hit | ✅ | cell_hovered signal |
| panel: doesn't press disabled cell | ✅ | disabled entry ignored |
| panel: focus navigation | ✅ | keyboard Right+Space |
| Query Row: uses HexCellButtonPanel | ✅ | offset_panel is HexCellButtonPanel |
| Query Row: radius/gap/padding sync | ✅ | across Mask/Reference |
| Query Row: offset update via panel press | ✅ | _send_panel_click |
| Distribution Editor: pattern uses layout entries | ✅ | center/ref positions match |
| Distribution Editor: draw signal uses layout-backed method | ✅ | connected |

全19件のテストが充足。`setting_sync` テストは Deductor Floor Source の spin sync を直接確認していないが、Mask/Reference で検証されており、実装の対称性から問題ない。
