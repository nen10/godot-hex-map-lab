# FB-00 Sub Tasks

## Task Resolution

task resolution:

- task candidate: feedback source adoption audit
  - goal / UX: 次の autopilot 実装者が4つの feedback を source of truth として扱える。
  - decision: adopt in this task.
  - summary: `ROADMAP.md` に feedback source、priority order、採用判断、順番調整ルールが明記されていることを確認する。
- task candidate: execution queue activation
  - goal / UX: Codex が人間承認待ちで止まらず、次の安全修正へ進める。
  - decision: adopt in this task.
  - summary: `IMPLEMENTATION_QUEUE.md` を current queue として使い、`FB-00` completion 後の next READY を明確にする。
- task candidate: dist freshness normal-test exclusion
  - goal / UX: roadmap 実行中の各 task が配布物更新に引きずられない。
  - decision: adopt in this task.
  - summary: `dist` freshness は通常 test gate ではなく final process task だけで扱うことを proof に含める。
- task candidate: analog test deferral
  - goal / UX: CLEAN UI 再編中に古い操作観察文書で UX を固定しない。
  - decision: adopt in this task.
  - summary: 新規 analog test を作らない方針を proof に含める。
- task candidate: implement FileDialog repair immediately
  - goal / UX: P0 疑惑をすぐ直す。
  - decision: defer to `FB-01`.
  - summary: `FB-00` は adoption proof task であり、FileDialog lifecycle 修正は次 task の独立 acceptance として扱う。
- task candidate: remove visible no-op controls immediately
  - goal / UX: first impression を悪化させる visible no-op を消す。
  - decision: defer to `FB-02`.
  - summary: no-op control repair は `FB-02` の独立 acceptance として扱う。

## Scheduled Tasks

No new Scheduled task is added by this task.

Reason:

- The roadmap already decomposes adopted feedback into `FB-01`, `FB-02`, Resource ownership, state transition, UI, screen, architecture, performance, test, manual, and final process tasks.
- `FB-00` can maximize value by making the adoption proof and next READY state unambiguous rather than adding another planning-only task.

## Completion Boundary

`FB-00` is complete when:

- The roadmap and queue are present and internally aligned.
- The 4 feedback sources and priority order are visible in the roadmap.
- The queue records `FB-00` proof and promotes valid dependency successors.
- `./tools/test.sh` has been run, or a test-environment blocker has been recorded.
