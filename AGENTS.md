# AGENTS.md

## 参照

必要な作業を発見・承認する。
基本方針は `README.md` と `docs/policy/` 以下を確認する。

- 計画作成: `docs/policy/PLANNING_POLICY.md`
- 開発領域ごとの設計判断: `docs/policy/DOMAIN_POLICY.md`
- 実装・検証・完了整理: `docs/policy/IMPLEMENTATION_POLICY.md`

- テスト実行と Test path: `docs/TEST.md`
- 自動テスト設計: `docs/policy/TEST_DESIGN_POLICY.md`
- アナログテスト: `docs/policy/ANALOG_TEST_POLICY.md`

## 作業方針

作業の一貫性ではなく目的の一貫性をとる。
作業の効率化のために簡単にできることがあれば記録したりtoolを作成してよい。
Godot開発におけるノウハウを随時 `docs/knowledge/DEV_GODOT.md` にdocumentationしてください。

## 実行メモ

- テスト実行は `tools/test.sh` を使用してよい。詳細は `docs/TEST.md` の 実行 セクションを参照。
- minimal に godot を headless 実行する場合、`--log-file .godot_user/<purpose>.log` を付けることでクラッシュを回避する。
