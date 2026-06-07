# ANALOG_TEST_POLICY.md

## 目的

この Policy 文書は、アナログテスト作成時の指針である。対象コードを実際に操作した場合の期待動作を、ユースケース、操作手順、コードリーディング検証、ユーザーによる操作結果または ChatGPT agent 判定の順で確認するための文書作成時に従う。

### アナログテスト

Editor Plugin 上の実操作で複数機能の結合性を確認できるユースケースを、擬似的な結合テスト・システムテストとして扱う検証文書のこと。

- アナログテストは実装完了要件とは独立に扱い、要件の洗い出し・機能改善のための能動的な開発サイクルを実現するテストケースである。
- アナログテストは [ユースケースの planning, 操作手順作成, コードリーディング検証, ユーザーによる操作結果または ChatGPT agent 判定] の順によって実行される。
- code reading によりユースケースを実現する機能に不足が確認された場合、機能追加・修正項目を計画できるように documentation する。
- コードリーディング検証結果を受けたあと、ユーザーの判断により操作テストを行う。
- ChatGPT agent は、渡された操作手順と観察結果がユースケースの結合性を確認する材料として十分かを判定できる。画面操作そのものの実施責任はユーザー判断に置く。
- アナログテストの実行はユーザー判断に責任を負うものであり、アナログテストとして実行不能な機能・マニュアルがプロジェクトに存在することはプロジェクトの瑕疵ではない。開発中に実行不能な "Operation Steps" が存在することは正常な開発プロセスである。

## 位置づけ

- アナログテストは `docs/TEST.md` の headless test / debug workflow を置き換えない。
- `docs/TEST.md` の Test path に列挙された自動テストは、実装有無を確認する主な根拠であり続ける。
- アナログテストは、ユーザー依頼時に作成・整理・判定する追加検証として扱う。
- `tests/analog_test/` 以下の操作手順マニュアルは、製品 manual でも仕様書でもない。ユースケースに基づく検証手順と観察記録である。
- `docs/manual/` への manual 追加は、ユーザーが要望するか、完了を承認した機能に対してのみ行う。

## CLEAN UI再編中の扱い

- CLEAN UI再編中は新規アナログテスト文書を作成しない。
- 既存 `tests/analog_test/` 文書は history / reference として保持する。
- 既存アナログテストは clean UX acceptance ではなく、現在の Test path の代替にしない。
- NEXT-03-style analog test pack は現在の roadmap queue には scheduled しない。
- UI改善後にユーザーが明示した場合だけ、アナログテスト作成を再開する。

## 適用条件

アナログテストを作成する対象は、次の条件を満たすものに限定する。

- Editor Plugin を使った実操作が検証として有効である。
- `docs/plan/` 以下で計画されている機能、または計画済み機能同士の結合が対象である。
- 単独 API や単一 helper の振る舞いではなく、複数の機能が一つのユースケースとして接続される。
- headless test だけでは、実際の Editor 操作、Dock 状態、Scene Tree 選択、viewport hit、保存・再読み込み、Undo / Redo などの流れを十分に説明しにくい。
- ユーザーまたは別 agent が手順に沿って結果を観察できる。

対象外:

- 個別関数の入力と出力だけで完結する実装項目。
- `tools/test.sh` に追加すべき通常の headless test。
- fallback 記述だけを根拠にした仕様確認。fallback は一時状態の報告であり、方針や期待動作の根拠にしない。

## 作成物

ユーザーがアナログテストの実施を依頼した場合、以下のファイルを作成する。

```text
tests/analog_test/<USE_CASE_ID>_ANALOG_TEST_<YYYY-MM-DD>.md
docs/review/<USE_CASE_ID>_CODE_READING_<YYYY-MM-DD>.md
```

必要に応じて、ANALOG_TEST 内に ChatGPT agent 判定用情報を追記する。分量が大きい場合は次のように分ける。

```text
tests/analog_test/<USE_CASE_ID>_CHATGPT_JUDGEMENT_<YYYY-MM-DD>.md
```

## 操作手順マニュアルのスキーム

アナログテストの操作手順マニュアルは、次の項目を持つ。

```md
# <USE_CASE_ID> Analog Test

## Metadata

- Status:
- Source plans:
- Target Editor Plugin area:
- Participating features:
- Created date:

## Use Case

- Actor:
- Goal:
- Scenario:
- Success state:

## Preconditions

- Godot project state:
- Addon state:
- Scene/resource files:
- Required node setup:
- Data to prepare:

## Inputs

- User operations:
- Editor selection:
- Resource files:
- Runtime/display settings:

## Outputs

- Visible Editor state:
- Resource mutations:
- TileMapLayer / HexTileMapLayer state:
- Saved files:
- Status text / logs:

## Operation Steps

1. ...

## Expected Observations

- ...

## Failure Signals

- ...

## Code Reading Verification

| Step | Expected program behavior | Code path | Evidence | Remaining risk |
| --- | --- | --- | --- | --- |

## ChatGPT Agent Judgement Packet

- Material to pass:
- Judgement criteria:
- Required answer format:

## Follow-up Test Candidates

- ...
```

## ユースケース作成 policy

ユースケースは、ユーザーが Editor Plugin で達成したい目的から書く。実装した関数名の列挙ではなく、操作の流れと観察できる状態を中心にする。

作成時に確認する情報:

- `README.md`
- `docs/TEST.md`
- 対象機能の `docs/plan/` 文書
- 関連する `docs/complete_on_test/` 文書
- 既存の `docs/manual/` 文書。ただし manual は仕様書ではなく、既存の使い方確認として参照する。

ユースケースには、少なくとも以下を含める。

- ユーザーが達成する目的。
- 関与する Editor Dock / Inspector / viewport / Scene Tree / resource。
- 入力となる操作、ファイル、設定。
- 出力として観察する UI 状態、resource 状態、TileMap 表示、保存結果。
- pass / fail を分ける観察条件。
- どの計画文書の結合性を確認するか。

## Codex コードリーディング検証 policy

操作手順マニュアルを作成した後、Codex は手順を実施した場合のプログラム動作をコードリーディングで検証する。

検証で行うこと:

- ユースケースに応じて作成された各操作 step について、Editor event handler、Dock control、resource mutation、TileMapLayer / HexTileMapLayer refresh、UndoRedo、save / load 等の code path を辿る。
- ユースケース実施に際して必要な外部入力が、別 step において作成されること、またはユーザーの操作として可能な状態であることを辿る。
- 期待動作が既存 test で確認されている場合は、該当する test file と test 名を記録する。
- 期待動作が code path から読めるが実行観察が必要な場合は、`Remaining risk` に明記する。
- code path が見つからない、または矛盾がある場合は、操作手順の pass とせず、修正候補・追加 test 候補として記録する。

根拠として扱えないもの:

- fallback 記述を仕様根拠として扱うこと。
- 実行していない操作を「実行済み」と記録すること。
- docs だけを根拠に実装状態を判定すること。

コードリーディング検証の判定語:

- `code_reading_pass`: 手順の期待動作に対応する code path と既存 test または十分な状態遷移が確認できる。
- `needs_runtime_observation`: code path は辿れるが、Editor 上の表示・操作感・viewport hit などの観察が必要である。
- `blocked_by_missing_trace`: 手順に対応する code path を確認できない。
- `test_candidate`: headless test、debug scene、または Editor workflow test に落とし込む価値がある。

## ChatGPT agent 判定 policy

ChatGPT agent は、アナログテストの操作手順と観察結果が、ユースケースの結合性を確認する材料として十分かを判定する。

ユーザーが ChatGPT agent に渡す材料:

- `tests/analog_test/` の操作手順マニュアル。
- Codex のコードリーディング検証結果。
- ユーザーが実際に操作した場合は、観察ログ、スクリーンショット、保存された resource の状態、発生したエラー。

操作手順マニュアルだけを渡す場合、ChatGPT agent は手順設計の妥当性を判定する。実行結果の pass / fail は、観察ログがある場合にだけ判定する。

判定基準:

- ユースケースが複数機能の結合性を確認している。
- precondition、入力、出力、観察点が明確である。
- pass / fail の境界が実際に観察できる。
- Codex のコードリーディング検証で残った risk が、観察手順または follow-up test 候補として扱われている。
- 期待動作が fallback や未承認の仕様に依存していない。

推奨回答形式:

```md
## Judgement

- Result: pass | conditional | fail
- Scope judged:
- Evidence:
- Missing observations:
- Follow-up test candidates:
```

ChatGPT agent の判定は、計画文書を `docs/complete_on_test/` へ移動する自動根拠にはしない。完了判断は、`docs/TEST.md` に記録された test、またはユーザーレビューで承認された範囲に基づいて行う。

## 実施フロー

1. ユーザーがアナログテスト対象の作成または実施を依頼する。
2. Codex が `README.md`、`docs/TEST.md`、対象の `docs/plan/` を確認する。
3. Codex が Editor Plugin による結合ユースケースを作成し、`tests/analog_test/` に操作手順マニュアルを書く。
4. Codex がコードリーディング検証を同ファイルまたは別ファイルに記録する。
5. ユーザーが必要なタイミングで操作手順を実施するか、ChatGPT agent に判定材料として渡す。
6. 判定結果から不足が見つかった場合、follow-up test 候補または `docs/plan/` の要望として整理する。

## 完了判定

アナログテスト文書は、次を満たすと作成完了とする。

- 対象ユースケースが Editor Plugin 操作として実施可能である。
- 入力、出力、resource、観察点が明確である。
- 各 step に対するコードリーディング検証結果がある。
- ChatGPT agent に渡す判定材料と判定基準が明示されている。
- 不足分が follow-up test 候補として記録されている。

## manual 作成

アナログテストがユーザーによって成功判定された場合、該当するUXを実現しうるマニュアルを作成してよい。
アナログテストとしての Operation Steps よりも一段抽象化した汎用的な作業手順と、機能の列挙性に注目しながら。各項目に対する簡潔な説明を付記する。
