# EDITOR_OVERLAY_REMAINS Adjacency Rule Set Validation 実装済み項目

`docs/plan/EDITOR_OVERLAY_REMAINS.md` の 7. Adjacency Rule Set Validation を実装済みとして扱う。

## 入出力

入力:

- Adjacency Rules text

出力:

- normalized rule dictionary
  - `default`: `String`
  - neighbor count: `int`
  - neighbor count / component count: `Vector2i`
- invalid entry list
- Dock / Adjacency Rule Editor のstatus text

不正entryはstatusに表示する。有効ruleが1件もない場合、parser は空rules `{}` を返し、Dock の Adjacency Overlay Generate は実行しない。

## 実装状況

- [x] `HexAdjacencyRuleSet.parse_rules_text_report()` を追加する
- [x] `2,1` 形式のrule keyを `Vector2i(2, 1)` へ正規化する
- [x] `default`、整数key、`整数,整数` 以外をinvalid entryとして報告する
- [x] Dock の Adjacency Rules rowにvalid rule countとinvalid entryを表示する
- [x] Adjacency Rule Editorにも同じvalidation statusを表示する
- [x] 有効ruleが0件の場合はAdjacency Overlay Generateを停止する

## テスト

- `tests/test_hex_adapter.gd`
  - `default` / count / count-component ruleのparse
  - `Vector2i` keyへの正規化
  - invalid entry report
  - 全invalid入力で空rulesを返すこと
  - probability clamp
- `tests/test_editor_plugin.gd`
  - Adjacency Rule Editorのstatus更新
  - Dockのvalid rule count表示
  - Dockのinvalid entry表示
  - Dock / Adjacency Rule Editorにfallback表示が残らないこと
  - 空Adjacency RulesではGenerateしないこと

確認コマンド:

```sh
./tools/test.sh
```

実行結果: 全テスト通過。
