# CLEAN-00 Implementation Plan

作成日: 2026-06-07

## Scope

対象:

- `AGENTS.md`
- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`
- `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/CLEAN-00_POLICY_RESET/`

対象外:

- product code
- resource schema 実装
- editor UI 実装
- new analog test
- `docs/TEST.md` の analog deferral marker

## Steps

1. Queue の `CLEAN-00` を `RUNNING` にする。
2. plan packet として `UX.md` / `POLICY.md` / `IMPLEMENTATION_PLAN.md` を作る。
3. `AGENTS.md` に clean roadmap の優先順位と analog deferral を明記する。
4. Autopilot orchestration から、互換性維持や migration helper をデフォルト上位規則にする記述を clean roadmap 向けに修正する。
5. Implementation / Test Design policy に、clean UX が headless test と compatibility より上位であることを明記する。
6. Queue を completion proof 付きで更新し、dependency sweep により `CLEAN-30` と `CLEAN-52` を `READY` にする。
7. `./tools/test.sh` を実行し、test result を `docs/review/autopilot/` に記録する。
8. Self-review を作成し、`repair-now` があれば同じ task 内で修正する。
9. `git diff --check` と intended files の確認後、completion commit を作る。
