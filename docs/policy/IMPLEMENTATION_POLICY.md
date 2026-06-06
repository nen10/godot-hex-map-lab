# IMPLEMENTATION_POLICY.md

## 目的

`docs/plan/` 以下の計画を実装へ落とし込む際の共通方針を定める。実装は、計画文書・方針文書・テストによる確認を接続し、後続の計画が依存できる単位として進める。

## 参照する方針

- 計画作成: `docs/policy/PLANNING_POLICY.md`
- 開発領域ごとの設計判断: `docs/policy/DOMAIN_POLICY.md`
- テスト実行と Test path: `docs/TEST.md`
- 自動テスト設計: `docs/policy/TEST_DESIGN_POLICY.md`
- アナログテスト: `docs/policy/ANALOG_TEST_POLICY.md`

## 実装単位

- 方針文書を元に、実装計画・documentation・実装・検証を着実に進める。
- 最小実装だけで閉じず、後続の実装が利用できる入出力、resource schema、helper、test fixture を残す。
- ただし、計画外の大きな再設計や manual 作成は、ユーザー要望または完了承認の対象になった場合に行う。
- fallback / hack は一時的な状態として扱い、仕様や UX 判断の根拠にしない。

## 着手順序

- 順序を問わない着手可能な課題では、最も大きな課題から取り組む。
- 細かい課題は別 agent に委譲できる。

## Documentation

実装計画または完了整理に記録する内容:

- 対象計画、対象ファイル、入出力インターフェース。
- resource file / scene file / saved document の schema。
- `docs/TEST.md` の Test path に接続するテスト概要。
- 実装できなかった範囲がある場合、必要なテストケース候補または `docs/plan/` の計画候補。

## 検証

- `docs/plan/` 以下で計画されている意味のある機能には、原則として自動テストまたは明示された interactive test を作成する。
- 実装有無の主な根拠は `docs/TEST.md` に記録された Test path と `tools/test.sh` の実行結果とする。
- 自動テストの追加・変更時は `docs/policy/TEST_DESIGN_POLICY.md` に従い、並列実行時に固定resourceや共有ログへ書き込まない。

## レビューと完了整理

- 主タスク完了ごとに reviewer が計画、実装、テスト、残リスクを確認しDocumentationする。
- review では 成果の確認のほか残リスクについては fix now / backlog and separate Design Flow / user validation / ignore and accepted risk に分類する。
- TEST によって計画済み機能が確認された場合、該当計画文書は `docs/complete_on_test/` 以下へ移動し、`docs/plan/` には未実装項目として残さない。
- レビューで課題が見つかった場合でも、後続の主タスクに支障がないものは計画候補または backlog として残し、実装済み内容は完了整理できる。

## Up scaling for next planning

完了要件とは独立に、実装項目に関連するユースケース及びアナログテストを作成し、開発イテレーションを進めることができる。

- Editor Plugin 操作など、自動テストでは観察しにくい結合ユースケースは `tests/analog_test/` のアナログテストとして扱える。
- アナログテストは実装完了要件の代替ではなく、要件抽出と改善計画の材料として扱う。
