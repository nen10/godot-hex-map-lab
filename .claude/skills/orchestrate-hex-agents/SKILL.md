---
name: orchestrate-hex-agents
description: Drive a Hex Map Kit queue task through the manage→route→verify→merge pipeline using the Codex (GPT-5.5) and opencode (DeepSeek) CLI agents. Use when delegating implementation to an external agent, running a competitive dual-run, doing UI sparring with DeepSeek, or gating an agent branch before it can be marked COMPLETE.
---

# Orchestrate Hex Map agents

You (Opus) are the orchestrator, not the implementer. Your leverage is in
**setting the contract and owning the verification gate** — not in hand-coding
through an unreliable executor. Read `docs/process/AGENT_ROSTER_AND_ROUTING.md`
once per session before driving a task.

## Roster (one line each)

- **Codex / GPT-5.5** = reliable executor. Faithful, tested, honest — but conservative.
- **opencode / DeepSeek** = ambitious explorer / sparring partner. Reaches further, but overclaims, under-tests, scope-creeps; **no sandbox → must be isolated and fully gated.**

## Pipeline

1. **Pick + read the task.** Get the `READY` task id and its row from the active
   `IMPLEMENTATION_QUEUE.md`. Read the matching `ROADMAP.md` entry.

2. **Write the contract (your job, before any agent runs).** State explicitly:
   - acceptance (the literal pass condition),
   - **depth**: `surface` | `integrated` | `decision` (see roster §6 — this is the
     single most important field; ambiguous depth is why Codex looks timid),
   - scope: the exact files the agent may touch; "do not edit other tasks' queue
     rows; do not mark anything COMPLETE",
   - tests required.

3. **Route** per roster §3:
   - bounded / unambiguous → **Codex**, autonomous.
   - exploratory / spike / "maximal version" / stubborn UI bug → **DeepSeek**, isolated.
   - high-value + ambiguous → **dual-run** both, then arbitrate.

4. **Run the agent (read CLI cheatsheet in roster §5).**
   - Codex: `codex exec -s workspace-write -C "$PWD" -o /tmp/codex_last.md "<contract>"`.
   - DeepSeek: **isolate first** — `git worktree add ../wt-ds -b agent/ds-<ID>`, then
     `opencode run --dir ../wt-ds -m <model> "<contract; this is a DRAFT>"`.
   - Do **not** trigger a billed agent run if the user only asked for setup; confirm first.

5. **Gate (never skip).** `python3 tools/verify_task.py --task <ID> --head <branch>`.
   - `ACCEPT` → proceed to merge/queue update.
   - `REJECT` → relay the exact findings to the executor for repair (Codex can
     usually self-repair; for DeepSeek, you often repair or re-route to Codex).
     Triage `WARN`s; don't auto-block on them.

6. **Merge + record (only after ACCEPT).** Merge/cherry-pick the branch, let the
   queue status flip to `COMPLETE`, ensure the proof-log entry exists, advance the
   pointer. For DeepSeek work, *you* (or Codex) make the queue edits — DeepSeek does not.

7. **Dual-run arbitration (when used).** Run the gate on both branches. Prefer the
   `ACCEPT`. If the `REJECT` branch has a better idea (e.g. DeepSeek's engine
   wiring), file it as a follow-up task and harvest it into the winner — don't ship
   the unverified branch.

## Hard rules

- Completion is **gate-decided, never self-attested**. `verify_task.py ACCEPT` is the only door to `COMPLETE`.
- DeepSeek output is a **draft on an isolated branch** until gated. Never let it write shared state.
- If you catch yourself asking Codex to "be bolder," fix the **contract depth** instead.
- Stop and ask the user before any **billed agent run** they didn't explicitly request, and before merging to a protected branch.

## Quick smoke test (no billed run)

```sh
codex --version && opencode --version
python3 tools/verify_task.py --task <ID> --head <branch>   # gate runs on git data only
```
