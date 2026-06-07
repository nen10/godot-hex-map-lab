# Implementation Queue Design Policy

## Purpose

承認済み Roadmap から `IMPLEMENTATION_QUEUE.md` を作成する指針を定める。

この文書は queue 実行 process ではない。status 更新、repair loop、commit は `docs/process/` に委ねる。

## Inputs

- `docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/UX_ROADMAP.md`
- 関連する評価・review・risk register
- `docs/policy/DOMAIN_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`

## Output

```text
docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/IMPLEMENTATION_QUEUE.md
```

## Queue file must include

1. Roadmap source path。
2. Queue operation process への参照。
3. Task table。
4. Dynamic follow-up area。
5. Current pointer。

Task table の最小列:

| column | meaning |
|---|---|
| `id` | 安定した task ID。 |
| `status` | 初期状態。実行中の更新規則は process に従う。 |
| `dependencies` | 完了している必要がある task。 |
| `plan_dir` | task ごとの `UX.md` / `POLICY.md` / `IMPLEMENTATION_PLAN.md` 置き場。 |
| `deliverable` | 完了時に得られる成果。 |
| `target files` | 主に触るファイル群。 |
| `acceptance / test path` | 完了判定の根拠。 |

## Task sizing

Task は、関数単位ではなく、意味のある UX / API slice として切る。

良い task:

- canonical Resource + adapter + save/load/validation test。
- Resource reference schema + sample asset + validator update。
- Workspace tab content + state contract test。
- Manual update after actual UI exists。
- Package integrity check after sample assets are stable。

悪い task:

- class を 1 個作るだけ。
- button を 1 個置く。 
- test に合わせて旧 UI を守る。
- plan だけ作って承認待ちにする。
- 互換維持や migration を理由なく残す。

## Dependency rules

- Resource / API cleanup は UI redesign より前に置く。
- UI screen redesign は manual update より前に置く。
- Test reset は採用 UX / API に合わせて置く。旧 test を守るために前倒ししない。
- Package / dist regeneration は sample asset と docs が安定した後に置く。

## Acceptance rules

Acceptance は「何ができるか」を書く。

- 旧互換を守ることを acceptance にしない。ただし Roadmap が明示した場合は例外。
- UI task の acceptance は、内部 node 名ではなくユーザーの作業目的に接続する。
- Test path は必要だが、test 都合で UX を歪めない。
- 完了していないが後続を止めない事項は follow-up candidate として扱う。

## Queue design checklist

- Roadmap の phase が task に過不足なく落ちているか。
- 各 task が単独で実装・検証・review できるか。
- dependencies が機械的に判定できるか。
- `READY` にすべき最初の task が明確か。
- process や commit 手順を書き込みすぎていないか。
