# Multi Layer Adjacency Rule Set Editor 実装済み項目

`docs/plan/MULTI_LAYER.md` のうち、Adjacency Reference 用の確率ruleを保存・編集・生成に渡す基本機能を実装済みとして扱う。

## 入出力

### HexAdjacencyRuleSet

入力:

- `rules_text`
  - `default=0.2;1=0.8;2,1=0.4` 形式

出力:

- probability rule dictionary
  - `"default"`
  - neighbor count `int`
  - count / components `Vector2i`
- invalid entry list

### HexAdjacencyRuleEditor

入力:

- initial rule text
- apply callback
- cancel callback

出力:

- apply 時の rules text

## 実装状況

- [x] `HexAdjacencyRuleSet` Resource を追加する
- [x] rule text を probability rule dictionary に変換する
- [x] probability を `0.0..1.0` に clamp する
- [x] rule text が空または全不正な場合、空rules `{}` を返す
- [x] `HexAdjacencyRuleEditor` で rule text を編集し、Apply callback に返す
- [x] Editor Dock の Adjacency Rules `Edit` button から rule editor を開く
- [x] Editor Dock の adjacency generation が `HexAdjacencyRuleSet` の parser を使う

## テスト

- `tests/test_hex_adapter.gd`
  - default / neighbor count / count-component key の parse
  - 全不正入力で空rulesを返すこと
  - probability clamp
- `tests/test_editor_plugin.gd`
  - `HexAdjacencyRuleEditor` が初期rule textを表示すること
  - Apply callback が編集後rule textを受け取ること
