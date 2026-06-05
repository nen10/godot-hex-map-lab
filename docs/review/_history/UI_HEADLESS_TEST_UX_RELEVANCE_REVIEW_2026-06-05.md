# UI_HEADLESS_TEST_UX_RELEVANCE_REVIEW_2026-06-05.md

## 対象

- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- 通常テスト設計方針: `docs/plan/policy/TEST_DESIGN_POLICY.md`

## 結論

UI headless test の多くは、Editor Dock の workflow、save / load、target apply、status 表示、Undo / Redo、Source Registry、Generate History などの UX に接続している。一方で、いくつかの項目は UX 上の利益そのものではなく、互換性、内部構造、技術的 regression guard として残っている
UI 改善に注目をするため、UX改善に干渉するテストケースが判明した場合はテストの修正・削除を優先する。「UX contract を守る test」と「技術 guard」を分けて扱う。
テストケースの存在は開発の結果であって、今後の開発や設計の根拠ではない。設計・開発の根拠はUXの提案・改善を指針とし、テストとして記述しない。

## UX 利益が弱い項目

### Source code 文字列検査

- 対象例: `EditorUndoRedoManager` を plugin から渡さないことの source 検査。
- 判定: 直接の UX ではなく、過去の Godot Editor headless / UndoRedo 互換問題を守る技術 guard。
- 扱い: 互換性 issue が解消するまで残せるが、UI workflow test ではなく technical regression test として明記する。

### exact label / wording test

- 対象例: `Browse .tres`、`Save As .tres`、`History Dir`、`Browse Atlas Image` の完全一致。
- 判定: 用語統一が UX 要件である範囲は有効。ただし handler や path selection の検証としては冗長になりやすい。
- 扱い: File / resource selection UX の改善後は、共通 Path Selector の semantic role、file mode、filter、status result を検証し、全ボタン文言の完全一致は最小化する。

### control tree の網羅的存在確認

- 対象例: `Hex Map Edit Dock` の各 control が作成されていること、disabled state の細部。
- 判定: workflow の入口となる command は UX に接続するが、内部 control の網羅は実装詳細に寄りやすい。
- 扱い: 「Loadできる」「Saveできる」「target statusが判断できる」のような user-visible result を主にし、control 存在確認は主要 command に限定する。

### stable tab / option name の過剰固定

- 対象例: Generate Dock の stable tab name、target list の class 表示、短い layer 名表示。
- 判定: ユーザーが選択判断に使う名称は UX に接続する。ただし exact string を過剰に固定すると、改善時に test が不要に壊れる。
- 扱い: 表示の意味が必要な項目は残し、単なる内部識別名は component-level technical guard に分ける。

### HexCellButton layout / panel の headless interaction 詳細

- 対象例: polygon hit、minimum size、keyboard focus navigation、disabled cell press suppression。
- 判定: accessibility / interaction component としては有効。Editor Dock の UX そのものを完全に保証するものではない。
- 扱い: component contract として残す。実際の見た目、密度、操作感は debug scene または analog test の責務に分ける。

### Distribution Editor recent custom state

- 対象例: recent custom distribution の static state と duplicate preset 保存。
- 判定: Distribution Editor workflow としては UX に接続するが、static state は並列化より case 内順序に依存する。
- 扱い: 現行は script process 内で reset しているため許容する。case 単位並列化を行う場合は state store を注入または case ごとに隔離する。

### Generate History の命名細部

- 対象例: `overlay-combination` 命名、history source 登録の細かい内部状態。
- 判定: traceability と data integrity の機能要件であり、直接の UI UX ではない。
- 扱い: Core / functional guard として残せる。UI headless test では、ユーザーが history を見つけられる status と保存結果を優先する。

### modal progress window 不生成

- 対象例: Generate 時に modal progress window を生成しないこと。
- 判定: modal blocker を避ける UX 価値はあるが、実体は実装方針の regression guard。
- 扱い: 「Dock 内 progress が表示され、cancel 可能で、modal に操作を奪われない」ユースケースへ接続する。source や node class の否定だけで完了扱いにしない。

### status text の細かい断片一致

- 対象例: Source Registry、Target Status、Last Edit、Save / Export detail の文字列断片。
- 判定: ユーザー判断に必要な情報は UX に接続するが、全文や細部の固定は文言改善を妨げる。
- 扱い: path、resource type、cell count、failure reason などの semantic token を検証し、自然文の exact wording は限定する。

## UX と独立して認める項目

- Core 座標、toric wrap、連結性、対称生成、seed による生成差分。
- Adapter の resource roundtrip、TileMapLayer cell mapping、TileSet configuration。
- HexTileMapLayer の command API、document snapshot、display state。
- Godot resource schema 互換、旧座標 helper、save-load integrity。

これらは UI UX とは独立した Core / Adapter 品質であり、通常テストとして残してよい。

## 今回の整理結果

- 通常テスト設計方針を `docs/plan/policy/TEST_DESIGN_POLICY.md` に追加した。
- `tools/test.sh` に `TEST_JOBS` と `HEX_MAP_TEST_RUN_ID` ベースの test run directory を追加した。
- `tests/test_editor_plugin.gd` と `tests/test_hex_adapter.gd` の固定 `.godot_user` resource 書き込みを、test run ごとの出力先へ分離した。

## 残り項目

- `tests/analog_test/` 内の手順には固定 `.godot_user` パス例が残る。これは通常テストの並列実行対象ではないが、同じ手順を複数回または複数人で実施する場合は、手順ごとに任意の保存先を指定する形へ更新する余地がある。
- Godot の import cache や ProjectSettings / EditorSettings を変更する新規テストを追加する場合は、case 単位で復元するか、通常テストではなく analog / debug workflow に分離する必要がある。
- `tests/test_editor_plugin.gd` は広い UI 面を1 script で順次検証している。将来さらにテスト時間が増える場合は、Edit Dock、Generate Dock、cell panel、Distribution Editor へ script を分割する。
