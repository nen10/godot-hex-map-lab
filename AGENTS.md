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

## Codex Autopilot

ロードマップ実装を自走する依頼では、次を入口にする。

- Orchestration: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- Queue: `docs/plan/autopilot/ROADMAP_IMPLEMENTATION_QUEUE_2026-06-06.md`
- Commit policy: `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`
- Roadmap source: `docs/review/roadmap/HEX_MAP_KIT_BRAINSTORM_UX_ROADMAP_2026-06-06.md`
- Skill: `.agents/skills/hex-map-codex-autopilot/SKILL.md`

Autopilot ロードマップ UX は人間により validate 済み。Plan 作成は承認ゲートではなく、同じ run で実装・テスト・self-review・repair・queue 更新まで進めるための作業単位である。

実装不足や review 指摘は、`repair-now` / `follow-up-ready` / `known-env-failure` / `accepted-risk` / `manual-optional` に分類する。`repair-now` は同じ task 内で修正する。`follow-up-ready` は queue に追加する。`manual-optional` は自動実装 loop を止めない。

Autopilot commit 方針: 1 queue task の `COMPLETE` / `COMPLETE_WITH_BACKLOG` ごとに 1 product completion commit を作る。`RUNNING` / `VERIFYING` / `REPAIR_NOW` の product code は completion commit にしない。`BLOCKED_BY_TEST_ENV` / `SPLIT_REQUIRED` / `SUPERSEDED` は docs-only state commit を作ってよい。由来不明の dirty tree を勝手に commit / stash / reset / overwrite してはいけない。
