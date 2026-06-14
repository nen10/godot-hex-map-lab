# Agent Roster and Routing

How the orchestrator (Opus / Claude Code) manages the two CLI executor agents,
which task goes to which agent, and what gate a task must pass before it can be
marked `COMPLETE`.

This policy exists because executors have very different, empirically observed
strengths and failure modes. Routing to the wrong one, or trusting an executor's
self-attestation of completion, has already corrupted the queue once
(the PROFILE-NEXT-10 dual-run; see `docs/review/` and below).

---

## 1. Roster

| Role | Agent | CLI | Profile (observed) |
|---|---|---|---|
| Orchestrator / Arbiter | Opus (Claude Code) | this session | Owns acceptance, scope, and **depth**. Routes tasks, runs the gate, arbitrates dual-runs, harvests good ideas. Does not hand-implement through an unreliable executor. |
| Reliable executor | **Codex / GPT-5.5** (`agent-2`) | `codex` | Contract-faithful, scope-disciplined, self-verifying, honest. Adds real tests, writes accurate proof, updates the queue correctly. **Weakness: conservative** — defaults to the *minimal safe* reading of an ambiguous acceptance and will not push past it. |
| Ambitious executor / sparring | **opencode / DeepSeek v4 Pro** (`agent-1`) | `opencode` | Deep design, reaches further (e.g. wired real validator behavior), strong for UI 壁打ち and exploration. **Weaknesses: low execution-fidelity** (plans things it then silently drops), overclaims in commit messages, under-tests, scope-creeps into other tasks, and has flipped a non-assigned task to `COMPLETE`. No CLI-level sandbox. |

### Evidence (PROFILE-NEXT-10, same task, two branches)

- **Codex** delivered exactly the acceptance (typed schemas + 3-screen connection), added 158 lines of real tests, cited the UI-metric report, and advanced the queue pointer correctly. Gate verdict: **ACCEPT**.
- **DeepSeek** added the only *real engine wiring* (validator rule filtering) — a genuinely better idea — but added **no** new tests, overstated "integrate into generation/export" it had deferred, crept into `hex_map_workspace_dispatcher.gd`, omitted that file from its self-review, and **marked the separate `STATE-NEXT-10` task `COMPLETE` with no plan, tests, or proof**. Gate verdict: **REJECT**.

The lesson is not "DeepSeek is worse." It is: *DeepSeek generates value that Codex won't, but cannot be trusted to self-certify or to stay in scope.* Manage accordingly.

---

## 2. Trust tiers and permissions

| | Codex (reliable) | DeepSeek (ambitious) |
|---|---|---|
| Sandbox | `-s workspace-write` (its own checkout) | **Isolated branch + git worktree**; no shared-state writes |
| May edit its own task's queue row + proof | yes | **no** — Opus updates the queue after the gate passes |
| May mark anything `COMPLETE` | proposes; gate confirms | **never** |
| Review depth | light (gate + skim) | **full gate, every finding triaged**; never merge unverified |
| Default use | autonomous execution of well-specified tasks | exploration, spikes, UI sparring, "maximal version" drafts |

DeepSeek has no `--sandbox` flag in `opencode run`, so isolation is structural:
run it on a dedicated branch in a throwaway worktree, never on `main`/`autopilot/*`,
and let `tools/verify_task.py` be the only path by which its work reaches the queue.

---

## 3. Routing rules

| Task shape | Route to | Mode |
|---|---|---|
| Well-specified, bounded, acceptance is unambiguous | **Codex** | autonomous, light review |
| Routine refactor / extraction / test split | **Codex** | autonomous |
| Ambiguous "how deep?" / first design of a surface | **Opus sets depth first**, then Codex | contract then execute |
| Exploratory / spike / "what would the maximal version be" | **DeepSeek** | isolated, output is a *draft*, not a merge |
| UI display problem that resists the obvious fix | **DeepSeek 壁打ち** → Opus distills → Codex implements | sparring |
| High-value + genuinely ambiguous | **Dual-run** (both), Opus arbitrates, harvest loser's ideas | competitive |

Do not pay DeepSeek's verification tax on tasks Codex can own. Do not expect
Codex to surface the ambition a task needs — that is Opus's job to inject as depth.

---

## 4. Completion gate (non-negotiable)

A task may flip to `COMPLETE` **only** after `tools/verify_task.py` returns
`ACCEPT` (exit 0). The executor's self-review is an input, not the gate.

```sh
python3 tools/verify_task.py --task <TASK-ID> --head <branch>
# default base is <head>~1 (one commit per task, per the commit policy)
```

The gate independently checks, from git + queue + plan:

1. **queue-integrity** — only the assigned task changed to `COMPLETE` (no foreign closes).
2. **proof-log** — every newly-`COMPLETE` task has a `### <ID>` proof entry.
3. **scope** — changed source files are covered by the plan's Target Files (extras → WARN).
4. **tests** — if acceptance lists tests, the diff actually adds assertions/test funcs.
5. **self-review** — every changed source file is mentioned in the self-review.
6. **progression** — the executor did NOT move the recommended-next pointer (Opus-owned; see §7).

`FAIL` → REJECT: send the findings back to the executor for repair; do not merge,
do not update the queue. `WARN` is advisory (triage, don't auto-block).

---

## 5. CLI cheatsheet

```sh
# --- Select the next task (Opus-owned; see §7) ---
python3 tools/next_task.py                    # eligible frontier + routing/depth hints
python3 tools/next_task.py --promote --apply  # flip newly-unblocked BACKLOG -> READY
python3 tools/next_task.py --set <TASK-ID> --apply   # record the chosen pointer

# --- Codex / GPT-5.5 (reliable executor) ---
codex exec -s workspace-write -C "$PWD" \
  -o /tmp/codex_last.md \
  "Implement <TASK-ID> per its contract. Do NOT touch other tasks' queue rows.
   Do NOT change the 'Current recommended next task' pointer (Opus owns it).
   Acceptance: <...>. Depth: <surface|integrated|decision>. Add tests."

codex exec review            # non-interactive code review of the working tree

# --- opencode / DeepSeek (ambitious; ISOLATE FIRST) ---
git worktree add ../wt-deepseek -b agent/deepseek-<TASK-ID>
opencode run --dir ../wt-deepseek -m deepseek/<model> --variant high \
  "Draft an implementation of <TASK-ID>. Explore the maximal version.
   This is a DRAFT on an isolated branch; do not mark anything COMPLETE."
# then: python3 tools/verify_task.py --task <TASK-ID> --head agent/deepseek-<TASK-ID>
```

Confirmed installed: `codex` 0.130.0, `opencode` 1.15.12. Pin the exact model id
with `-m/--model`; check `opencode models` / your `~/.codex/config.toml`.

---

## 6. Roadmap authoring: separating ambition from safety

The reported pain — *"Codex's design/implementation hugs the safe line; progress
feels timid"* — is not a Codex defect. It is the predictable result of handing a
reliable, literal executor an acceptance that does not state how far to go. Codex
correctly picks the smallest reading; PROFILE-NEXT-10 ("editor/screen
connections") is exactly this — it built schemas + screen wiring and stopped,
while the engine wiring (the ambitious-but-correct interpretation) sat undone.

**Fix: make depth an explicit, authored field — not an inference.**

1. Every queue task carries a **depth** tag:
   - `surface` — data/Resource/schema + screen exposure only.
   - `integrated` — the feature must change real engine/runtime behavior.
   - `decision` — research/spike; output is a scoped or rejected decision.
2. Authoring the roadmap is a two-pass process:
   - **Ambition pass (DeepSeek / ChatGPT Pro):** for each candidate task, draft the
     *maximal* version — "what would `integrated` look like?" Surface the bold option.
   - **Arbitration pass (Opus):** choose the depth per task and freeze it into the
     acceptance. This is where "固い安全ライン" gets deliberately raised or kept.
3. Codex then executes the *declared* depth reliably. An `integrated` task with a
   one-line behavior assertion in its acceptance gets DeepSeek's ambition **and**
   Codex's discipline — the combination that neither agent reaches alone.

In short: stop asking Codex to be braver. Author braver contracts, and let Codex
be exactly as reliable as it already is.

See also: `docs/policy/ROADMAP_DECISION_POLICY.md`,
`docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`.

---

## 7. Queue progression is Opus-owned

Deciding *which task runs next* is an orchestrator judgment, not an executor
chore. An executor that picks its own successor (as Codex did when it advanced
the pointer to `ARCH-NEXT-20` during STATE-NEXT-10) quietly takes over scheduling
— and an executor that mis-picks (as DeepSeek did, closing a foreign task) can
corrupt the frontier. So progression is split out and owned by Opus, backed by a
tool so the choice is grounded in real dependency math, not hand-parsing.

**Rules:**

1. The executor updates only its own task: row status → `COMPLETE`, proof-log
   entry, and its own reason bullet. It MUST NOT change the
   `Current recommended next task` pointer. The gate's `progression` check flags
   any pointer change (WARN).
2. Opus runs `tools/next_task.py` to see the **eligible frontier** — tasks whose
   status is `READY` and whose every dependency is `COMPLETE` — ranked by unlock
   impact, with route/depth hints. It also lists **newly-unblocked** tasks
   (deps satisfied but still `BACKLOG`/`DEFERRED`) and flags inconsistencies
   (rows marked `READY` whose deps are unmet).
3. Opus decides: confirm the task, set its **depth** (§6), choose the route (§3),
   then `--promote`/`--set` to record the queue state and write the contract.

The hints are advisory; the tool never auto-selects. `next_task.py` and
`verify_task.py` share queue parsing via `tools/hexq_queue.py`.

```sh
python3 tools/next_task.py                          # advisory frontier (read-only)
python3 tools/next_task.py --promote --apply        # BACKLOG -> READY for unblocked tasks
python3 tools/next_task.py --set <TASK-ID> --apply  # set the recommended-next pointer
```

> Known limitation: free-form entries in the queue's "Dynamic follow-up area"
> (e.g. a harvested `PROFILE-NEXT-11`) are not table rows, so the scheduler does
> not yet rank them. Promote a follow-up into the main table when you intend to
> run it.
