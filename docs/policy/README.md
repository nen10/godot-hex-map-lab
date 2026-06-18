# Policy Index


このディレクトリの文書は、ロードマップ、計画、実装、テストの判断を揃えるために使う。Queue の status 更新、repair loop、commit などの手順は `docs/process/` に置く。

## Files

| file | 責務 |
|---|---|
| `DOMAIN_POLICY.md` | Hex Map Kit の設計判断の上位原則。Core / Adapter / UI / Docs / Tests の責務境界。 |
| `ROADMAP_DECISION_POLICY.md` | feedback と承認済みブレストから Roadmap を作成する指針。 |
| `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` | Roadmap から implementation queue を作成する指針。 |
| `PLANNING_POLICY.md` | queue task ごとの `UX.md` / `POLICY.md` / `IMPLEMENTATION_PLAN.md` の書き方。 |
| `DESIGN_REVIEW_POLICY.md` | Roadmap / queue / task packet / 実装後成果物を設計レビューする判断基準。 |
| `IMPLEMENTATION_POLICY.md` | 実装時の判断基準。互換性、fallback、docs、検証の扱い。 |
| `TEST_DESIGN_POLICY.md` | 自動テストをどう設計するか。 |
| `ANALOG_TEST_POLICY.md` | ユーザー指示がある場合のアナログテスト作成指針。 |

## Boundary

- Roadmap を決める: `ROADMAP_DECISION_POLICY.md`
- Roadmap を queue に変換する: `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`
- Roadmap / queue / task packet / 実装後成果物を設計レビューする: `DESIGN_REVIEW_POLICY.md`
- Queue を実行する: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- Queue status を更新する: `docs/process/QUEUE_OPERATION_RULES.md`
- Commit する: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`
- Test を実行する: `docs/TEST.md`
- Test の設計・coverage 記録方針を決める: `TEST_DESIGN_POLICY.md`
