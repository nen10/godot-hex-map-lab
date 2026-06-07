# Codex Autopilot Commit Policy

作成日: 2026-06-06  
対象: `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md` に従う roadmap implementation

---

## 0. 結論

Autopilot の基本単位は、**1 queue task の `COMPLETE` / `COMPLETE_WITH_BACKLOG` ごとに 1 commit** とする。

これは人間承認ゲートではない。`COMPLETE` 判定は、queue acceptance、Test path、`./tools/test.sh`、self-review、`repair-now` が空であることによって決まる。

```text
READY
  -> RUNNING
  -> VERIFYING
  -> REPAIR_NOW if needed
  -> REVIEWING
  -> COMPLETE or COMPLETE_WITH_BACKLOG
  -> commit
  -> next READY task
```

---

## 1. Commit の役割

Autopilot commit は、以下のために行う。

1. task ごとの完成境界を Git history に固定する。
2. regression が出たときに bisect しやすくする。
3. queue state、test result、self-review、実装差分を同じ単位で保持する。
4. 次の Autopilot run が、どこから続ければよいかを判断しやすくする。
5. 長時間 run の途中で、完了済み成果物を失わないようにする。

Commit は「作業途中の保存」ではなく、「task completion proof」である。

---

## 2. Commit してよい状態

### 2.1 Product completion commit

以下の status は commit してよい。

| status | commit 可否 | 理由 |
|---|---:|---|
| `COMPLETE` | yes | acceptance と test proof を満たす。 |
| `COMPLETE_WITH_BACKLOG` | yes | acceptance は満たし、非blocking follow-up が queue に追加済み。 |

### 2.2 State commit

以下は product completion ではないが、queue を再開可能にするために docs-only commit してよい。

| status | commit 可否 | 条件 |
|---|---:|---|
| `BLOCKED_BY_TEST_ENV` | docs-only yes | Godot binary 欠落など、環境不足の記録だけ。実装 phase を complete にしない。 |
| `SPLIT_REQUIRED` | docs-only yes | 子 task を queue に追加し、元 task の状態を閉じる。 |
| `SUPERSEDED` | docs-only yes | 吸収先 task と理由を queue に明記する。 |

State commit の prefix は `autopilot-state` を使う。product completion commit と混同しない。

### 2.3 Commit しない状態

以下の status では commit しない。

| status | 理由 |
|---|---|
| `RUNNING` | 作業途中。完成境界ではない。 |
| `VERIFYING` | test proof が確定していない。 |
| `REPAIR_NOW` | acceptance 未達。次 task に進めない。 |
| `BACKLOG` / `READY` | 実装成果物ではない。 |

例外として、queue 整理だけの docs-only state commit は 2.2 に従う。

---

## 3. Branch / worktree 方針

Autopilot は作業ツリーをそのまま使用して良い。single branchにcommitを積み重ねていく。
人間の作業は別のブランチで作業している前提とする。

dirty tree の扱い:

1. Autopilot 自身の前回未完了変更で、queue status が `RUNNING` / `REPAIR_NOW` の場合は続行してよい。
2. 由来不明の変更はあまり触らないようにするが task と干渉する場合編集して良い。

Codex は作業外ブランチの状態を変更しない。

### 3.1 rollback が必要な場合

history rewrite ではなく revert commit を使う。

```sh
git revert <bad_commit>
```

ただし revert も task として queue / review に記録する。
rollback は原則直前の commit に対してのみ行う。
cherry-pick が必要な場合は作業を中断して状況を記録する。

---

## 4. Commit timing

Commit は、次の順序で行う。

```text
1. 実装完了
2. tests / docs/TEST.md 更新
3. ./tools/test.sh
4. self-review 作成
5. repair-now が空になるまで修正
6. queue proof 更新
7. git diff --check
8. git status --short
9. commit
10. 次の READY task へ進む
```

`queue proof` は同じ commit の hash を自分自身に書けないため、commit hash を必須にしない。queue には branch、date、test command、review path、major files を書く。commit hash は Git history 側が proof になる。

後続 task が前 task の commit hash を参照したい場合だけ、次 task の docs で `previous_commit` として記録してよい。

---

## 5. Commit message format

### 5.1 Product completion commit

```text
autopilot(<TASK_ID>): <imperative summary>

Status: COMPLETE | COMPLETE_WITH_BACKLOG
Queue: docs/plan/<date>_<roadmap_id>/IMPLEMENTATION_QUEUE.md
Plan: docs/plan/<date>_<roadmap_id>/<TASK_ID>_<slug>/
Review: docs/review/autopilot/<TASK_ID>_SELF_REVIEW_<date>.md
Tests:
- ./tools/test.sh

Major changes:
- <file or component>
- <file or component>

Follow-ups:
- none
```

### 5.2 State commit

```text
autopilot-state(<TASK_ID>): <state update summary>

Status: BLOCKED_BY_TEST_ENV | SPLIT_REQUIRED | SUPERSEDED
Reason: <short reason>
Queue: docs/plan/<date>_<roadmap_id>/IMPLEMENTATION_QUEUE.md
Docs:
- <state/review/test-env report>
```

---

## 6. One task, one completion commit

原則:

```text
1 COMPLETE task = 1 product completion commit
```

ただし、以下は例外として扱う。

### 6.1 Task が大きすぎる場合

1 commit に入る diff が大きすぎて review / bisect の意味が薄れる場合、Codex は `SPLIT_REQUIRED` にして子 task を queue に追加する。

分割基準:

- saved resource schema と editor UI と migration が同一 task に詰まっている。
- `hex_map_gen_dock.gd` と `hex_map_edit_tool.gd` の両方に広い変更が入る。
- new resource / adapter / UI / runtime sample / docs が一度に入る。
- `./tools/test.sh` 失敗時に原因範囲を絞れない。

分割は人間承認なしで行う。ただし、roadmap UX を減らしてはいけない。

### 6.2 Repair commit

`COMPLETE` commit 後に後続 task で regression が見つかった場合、前の commit を書き換えない。`REPAIR-<source_task>` または該当 feature task の `repair-now` として queue に追加し、修正完了時に別 commit する。

原則として history rewrite はしない。

### 6.3 Docs-only cleanup

typo、リンク修正、queue 表記修正などが task acceptance に直接関係する場合は、その task の completion commit に含める。

関係しない docs cleanup は、dynamic queue に `DOCS-*` task として追加してから commit する。

---

## 7. Pre-commit checklist

Codex は commit 前に以下を確認する。

```text
[ ] queue status is COMPLETE or COMPLETE_WITH_BACKLOG, or this is an allowed state commit
[ ] repair-now is empty
[ ] self-review exists
[ ] test result exists
[ ] docs/TEST.md updated if tests changed
[ ] queue proof is updated
[ ] git diff --check passes
[ ] git status --short contains only intended files
[ ] no generated cache, .godot user state, or local-only files are staged
[ ] no unrelated human changes are staged
```

推奨 command:

```sh
git diff --check
git status --short
git add <intended files>
git diff --cached --stat
git diff --cached --check
git commit -m "autopilot(<TASK_ID>): <summary>" -m "<body>"
```

---

## 8. Git identity

Autopilot 環境で `git commit` が user identity 不足で失敗した場合、repo-local config だけを設定してよい。

```sh
git config user.name "Codex Autopilot"
git config user.email "codex-autopilot@example.invalid"
```

global config は変更しない。

---

## 9. Push / PR policy

Commit と push / PR は分ける。

### 9.1 Local / app run

- `COMPLETE` ごとに local commit する。
- push は run の最後、または phase chunk の区切りでよい。
- push 前に `git log --oneline --decorate -n 10` と `git status --short` を確認する。

### 9.2 Cloud / GitHub run

- cloud が PR を作る場合も、commit は task completion 単位にする。
- PR は複数 task commit を含んでよい。
- PR description には完了 task 一覧、test proof、known env issue、follow-up queue を書く。

### 9.3 Merge policy

Autopilot は public release upload や main branch merge を必須操作にしない。merge / release は最終配布判断であり、Autopilot の連続実装ループとは別の境界とする。

---

## 10. 障害と対処

| 障害 | 対処 |
|---|---|
| test environment がない | `BLOCKED_BY_TEST_ENV` state commit。implementation phase は complete にしない。 |
| task が commit として大きすぎる | `SPLIT_REQUIRED` state commit 後、子 task を queue に追加。 |
| dirty tree | task範囲に干渉する項目は編集可 |
| git identity missing | repo-local `git config` のみ設定。 |
| binary / generated artifact churn | `.gitignore` / intended files を確認。不要なら stage しない。 |
| later regression | history rewrite せず repair task commit。 |
| queue に commit hash を書けない | queue は branch/date/proof を記録し、hash は Git history を canonical proof とする。 |
| PR が巨大化する | commit は task 単位を維持し、PR は phase / milestone 単位で切ってもよい。 |

---

## 11. Autopilot prompt fragment

```text
Follow docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md.
When a queue task reaches COMPLETE or COMPLETE_WITH_BACKLOG, create exactly one product completion commit for that task.
Do not commit RUNNING, VERIFYING, or REPAIR_NOW work.
Allowed docs-only state commits are BLOCKED_BY_TEST_ENV, SPLIT_REQUIRED, and SUPERSEDED.
After committing, continue to the next READY task if context remains.
```
