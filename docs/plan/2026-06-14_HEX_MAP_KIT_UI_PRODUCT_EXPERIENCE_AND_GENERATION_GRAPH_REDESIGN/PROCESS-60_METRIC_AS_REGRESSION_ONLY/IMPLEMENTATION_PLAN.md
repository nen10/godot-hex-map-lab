# PROCESS-60 IMPLEMENTATION PLAN

## Scope

Metric policy/process wording を、回帰検知としての扱いへ揃える。

含む:
- UI metric policy の役割定義更新。
- `docs/TEST.md` のレポート説明更新。
- `tools/test.sh` の metric suite コメント更新。

含まない:
- Metric collector / evaluator の削除。
- P0 regression check の無効化。
- Editor UI 変更。

## Target Files

- `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`
- `docs/TEST.md`
- `tools/test.sh`

## Planned Steps

1. Policy 冒頭と severity / task-type acceptance 節を、metric pass が acceptance proof ではない形に更新する。
2. `docs/TEST.md` に P0/P1 の扱いを regression/report として明記する。
3. `tools/test.sh` に metric suite が regression check であるコメントを追加する。
4. `./tools/test.sh` を実行する。
5. self-review / proof log / queue status を更新する。

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Metric が regression signal として明文化されている。
- UI/graph task の合格根拠は experiential DoD であることが policy から読める。
- 標準テストが成功する。
