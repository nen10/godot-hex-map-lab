

  panel.configure({
        "shape_kind": "custom",
        "shape_cells": shape_cells,
        "flat_top": _effective_flat_top,
        "cell_radius": 16.0,
        "cell_gap": 0.0,
        "padding": Vector2(8, 8),
        "center_cell": HexVector.zero(),
        "symmetric_about_anchor": true,    # ← 追加：anchor 基準で余白を対称化
        "anchor_cell": HexVector.zero(),   # ← 追加：weight セルを中心に固定
        "pressable_cells": pressable,
        "label_by_cell": labels,
        "metadata_by_cell": metadata,
        "show_labels": true,
  })

  - anchor_cell を省略しても、symmetric_about_anchor = true なら center_cell（ここでは HexVector.zero()）が自
    動で anchor になります。なので実質 "symmetric_about_anchor": true だけでもOKです。

  - symmetric_about_anchor = true のとき report_natural_minimum（既定 true）は anchor 対称の natural サイズを
    min size として返します。なので panel.custom_minimum_size = Vector2(96, 88) の固定枠は外せます（外すと各
    refcount の中身にぴったり、かつ同一 row 内は全部同じ幅になって行が揃います）。残したい場合は floor として
    併用も可。

  - setter でも指定できます: panel.symmetric_about_anchor = true /
    panel.set_layout_anchor_cell(HexVector.zero())。


  これで、generation > や references で非対称になっている形でも、weight セルが panel の中心に固定されます。


 ## Icon 表示

  各 cell の metadata に以下を指定できます。

  metadata[cell_key] = {
        "icon": Texture2D,                 # preload/load した任意 Texture2D
        # または
        "icon_name": "SomeEditorIconName", # theme icon 名
        "icon_theme_type": "EditorIcons",  # 省略時 EditorIcons

        "icon_only": true,                 # hex fill/outline と label を隠し、icon だけ表示
        "hide_shape": true,                # hex fill/outline だけ隠す
        "hide_label": true,                # label だけ隠す

        "icon_scale": 1.4,                 # cell_radius に対する倍率
        "icon_rotation_degrees": 0.0,      # degree 指定
        "icon_rotation": 0.0,              # radian 指定
        "icon_orient_to_anchor": true,     # anchor -> cell 方向へ自動回転
        "icon_modulate": Color.WHITE,      # tint
  }

  icon_only: true の場合は、セル自体の六角形と label は描かず、アイコンだけが cell center に置かれます。
  なので Markov の進行方向セル ">" の代替にそのまま使えます。

  ## inspector 側の使い方例

  一番堅いのは、addon 内に SVG/PNG を置いて preload() する形です。

  const MARKOV_STEP_ICON := preload("res://addons/hex_map_kit/editor/icons/markov_step_arrow.svg")

  そして _markov_state_panel() の generation cell 部分をこうします。

  if generation_direction != null:
        var generation_key: String = generation_direction.key()
        shape_cells.append(generation_direction)

        # 既存の ">" label は不要。残しても icon_only で隠れますが、
        # semantic にも消した方がきれいです。
        # labels[generation_key] = ">"

        metadata[generation_key] = {
                "icon": MARKOV_STEP_ICON,
                "icon_only": true,
                "icon_scale": 1.35,
                "icon_orient_to_anchor": true,
                "icon_modulate": Color(0.45, 0.68, 1.0),
        }

        pressable[generation_key] = false

  icon_orient_to_anchor: true は、anchor -> その cell の方向へ icon を回します。
  この場合、前回入れた symmetric_about_anchor と一緒に使うと自然です。

  panel.configure({
        "shape_kind": "custom",
        "shape_cells": shape_cells,
        "flat_top": _effective_flat_top,
        "cell_radius": 16.0,
        "cell_gap": 0.0,
        "padding": Vector2(8, 8),
        "center_cell": HexVector.zero(),
        "symmetric_about_anchor": true,
        "anchor_cell": HexVector.zero(),
        "pressable_cells": pressable,
        "label_by_cell": labels,
        "metadata_by_cell": metadata,
        "show_labels": true,
  })

  ## アイコンの向きについて

  icon_orient_to_anchor は テクスチャの右向き（+X）を基準方向として扱います。

  つまり、SVG/PNG 側で右向き矢印を作っておくと：

  - +q 側なら右向き
  - 斜め方向なら自動で斜めに回転
  - 必要なら icon_rotation_degrees で補正

  できます。

  例えば、元アイコンが上向きなら：

  "icon_rotation_degrees": -90.0,
  "icon_orient_to_anchor": true,

  みたいに補正できます。

  ## EditorIcons を使う場合

  Godot editor theme のアイコン名を直接指定することもできます。

  metadata[generation_key] = {
        "icon_name": "任意のEditorIcons名",
        "icon_theme_type": "EditorIcons",
        "icon_only": true,
        "icon_scale": 1.25,
        "icon_orient_to_anchor": true,
        "icon_modulate": Color(0.45, 0.68, 1.0),
  }

  ただし EditorIcons 名は theme / editor context に依存するので、addon 内 SVG を preload する方式の方が見た目
  の再現性は高いです。
  「Godot で簡単に参照」という意味では、res://addons/.../icons/*.svg を置くのが一番扱いやすいと思います。


  ## 4. HexCellButton 側のイベント管理設計

  今回の設計はこう分けています。

  ### HexCellButtonPanel が持つ責務

  - クリック/キーボード activation の統一処理
  - toggle state の保持
  - toggle に応じた見た目変更
  - cell_toggled(entry, pressed) の発火
  - update_cell() による live visual update
  - rebuild なしの label / fill / icon / metadata 更新

  追加 API:

  func set_toggle_cells(cells: Dictionary) -> void
  func set_cell_toggled(cell, pressed: bool, emit_signal_too: bool = false) -> bool
  func is_cell_toggled(cell) -> bool
  func get_toggle_states() -> Dictionary

  func update_cell(cell, patch: Dictionary) -> bool
  func set_cell_fill_color(cell, color: Color) -> bool
  func set_cell_label(cell, text: String, label_color = null) -> bool

  ### 呼び出し側が持つ責務

  - 最終的な domain data / params の保持
  - dialog OK / Apply / Cancel の commit timing
  - SpinBox など外部 control の値を panel に反映すること

  つまり、HexCellButtonPanel は UI interaction と presentation state の即時反映を担当し、inspector は 意味デー
  タの反映と commitだけを担当する形です。

  これにより：

  - Markov SpinBox: value_changed -> panel.update_cell(...)
  - Adj. toggle: panel internal toggle -> cell_toggled -> patterns 更新
  - geometry 変更がない更新では rebuild しない
  - クリック直後の視覚 feedback が速い

  という構成になっています。
