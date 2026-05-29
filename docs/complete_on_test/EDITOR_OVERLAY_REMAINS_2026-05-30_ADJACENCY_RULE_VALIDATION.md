# EDITOR_OVERLAY_REMAINS Adjacency Rule Set Validation 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 7. Adjacency Rule Set Validation を実装済みとして扱う。

## 入出力

入力:

- Adjacency Rules text
- fallback probability

出力:

- normalized rule dictionary
  - `default`: `String`
  - neighbor count: `int`
  - neighbor count / component count: `Vector2i`
- invalid entry list
- fallback使用flag
- Dock / Adjacency Rule Editor のstatus text

不正entryは生成を止めず、statusに表示する。有効ruleが1件もない場合はfallback probabilityを `default` ruleとして使う。

## 実装状況

- [x] `HexAdjacencyRuleSet.parse_rules_text_report()` を追加する
- [x] `2,1` 形式のrule keyを `Vector2i(2, 1)` へ正規化する
- [x] `default`、整数key、`整数,整数` 以外をinvalid entryとして報告する
- [x] Dock の Adjacency Rules rowにvalid rule count、fallback、invalid entryを表示する
- [x] Adjacency Rule Editorにも同じvalidation statusを表示する
- [x] 既存の生成は有効ruleとfallbackで継続する

## テスト

- `tests/test_hex_adapter.gd`
  - `default` / count / count-component ruleのparse
  - `Vector2i` keyへの正規化
  - invalid entry report
  - fallback使用flag
  - probability clamp
- `tests/test_editor_plugin.gd`
  - Adjacency Rule Editorのstatus更新
  - Dockのvalid rule count表示
  - Dockのinvalid entry表示
  - Dockのfallback default表示

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
