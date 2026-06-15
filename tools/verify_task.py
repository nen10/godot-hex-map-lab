#!/usr/bin/env python3
"""Independent task verification gate for the Hex Map Kit autopilot.

This tool is the *completion gate* described in
`docs/process/AGENT_ROSTER_AND_ROUTING.md`. It runs AFTER an executor agent
(Codex / opencode) finishes a queue task, and decides whether the task may
flip to `COMPLETE`. Completion is NOT self-attested by the executor: this
gate re-derives the truth from git + the queue + the plan, independently of
the agent's own self-review.

It encodes the lessons from the PROFILE-NEXT-10 dual-run incident:

  - An executor must not flip the status of a task it was not assigned.
  - Any task marked COMPLETE must have a proof-log entry.
  - A task whose acceptance lists tests must actually add test assertions.
  - Changed source files should be covered by the plan's Target Files.
  - The self-review must mention every source file the commit changed.
  - Queue *progression* (the recommended-next pointer) is orchestrator-owned;
    an executor changing it is flagged.

Usage:
  python3 tools/verify_task.py --task PROFILE-NEXT-10
  python3 tools/verify_task.py --task PROFILE-NEXT-10 --head agent-2 --base agent-2~1

Defaults: --head HEAD, --base <head>~1 (one commit per task, per the commit
policy). Override --base for multi-commit tasks.

Exit code 0 = no FAIL findings (WARN allowed). Exit code 1 = at least one FAIL.
Stdlib only; shares queue parsing with tools/hexq_queue.py.
"""

from __future__ import annotations

import argparse
import re
import sys

import hexq_queue as q

# Source roots that count as "code" for scope / test checks. Planning artifacts
# (docs/plan, docs/review) are expected to change and are excluded.
CODE_ROOTS = ("addons/", "tests/", "tools/", "scripts/")
TEST_ROOTS = ("tests/",)


class Finding:
    def __init__(self, level: str, check: str, message: str):
        self.level = level  # PASS | WARN | FAIL
        self.check = check
        self.message = message


def extract_paths(text: str) -> set[str]:
    """Pull file-path-looking tokens out of a markdown doc."""
    paths: set[str] = set()
    for m in re.finditer(r"`([^`]+)`", text):
        tok = m.group(1).strip()
        if "/" in tok and re.search(r"\.\w+$", tok):
            paths.add(tok)
    for m in re.finditer(r"(?:addons|tests|tools|scripts)/[\w./-]+\.\w+", text):
        paths.add(m.group(0))
    return paths


def diff_name_only(base: str, head: str, *paths: str) -> list[str]:
    out = q.git("diff", "--name-only", base, head, "--", *paths)
    return [line for line in out.splitlines() if line]


def diff_added_lines(base: str, head: str, *paths: str) -> list[str]:
    out = q.git("diff", base, head, "--", *paths)
    return [line[1:] for line in out.splitlines()
            if line.startswith("+") and not line.startswith("+++")]


def covered(changed: str, targets: set[str]) -> bool:
    base = changed.rsplit("/", 1)[-1]
    for t in targets:
        if changed == t or changed in t or t in changed:
            return True
        if base == t.rsplit("/", 1)[-1]:
            return True
    return False


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--task", required=True, help="Task id, e.g. PROFILE-NEXT-10")
    ap.add_argument("--head", default="HEAD", help="Ref with the finished task (default HEAD)")
    ap.add_argument("--base", default=None, help="Ref before the task (default <head>~1)")
    ap.add_argument("--queue", default=None, help="Queue path override")
    args = ap.parse_args()

    task = args.task
    head = args.head
    base = args.base or f"{head}~1"
    findings: list[Finding] = []

    queue_path = args.queue or q.find_queue_path(head, task)
    if not queue_path:
        print(f"FAIL: could not locate an IMPLEMENTATION_QUEUE.md containing `{task}` at {head}")
        return 1

    head_text = q.git_show(head, queue_path) or ""
    base_text = q.git_show(base, queue_path) or ""
    head_rows = q.parse_queue_rows(head_text)
    base_rows = q.parse_queue_rows(base_text)
    # Proof entries live in a sibling PROOF_LOG.md (split out to keep the queue lean).
    # Search both so old commits (entries in the queue) and new ones (entries in the
    # proof log) both verify.
    proof_log_path = queue_path.rsplit("/", 1)[0] + "/PROOF_LOG.md"
    proof_text = (q.git_show(head, proof_log_path) or "") if "/" in queue_path else ""
    proof_search = head_text + "\n" + proof_text

    # ---- Check 1: queue status integrity --------------------------------
    newly_complete = [
        t for t, r in head_rows.items()
        if r["status"] == "COMPLETE" and base_rows.get(t, {}).get("status") != "COMPLETE"
    ]
    foreign = [t for t in newly_complete if t != task]
    if foreign:
        findings.append(Finding(
            "FAIL", "queue-integrity",
            f"executor flipped task(s) it was not assigned to COMPLETE: {', '.join(foreign)} "
            f"(assigned task was {task})",
        ))
    else:
        findings.append(Finding("PASS", "queue-integrity",
                                "only assigned task status changed to COMPLETE"))

    if head_rows.get(task, {}).get("status") != "COMPLETE":
        findings.append(Finding(
            "WARN", "assigned-status",
            f"{task} is not COMPLETE at {head} (status={head_rows.get(task, {}).get('status')})",
        ))

    for t in newly_complete:
        if not re.search(rf"^###\s+{re.escape(t)}\b", proof_search, re.MULTILINE):
            findings.append(Finding("FAIL", "proof-log",
                                    f"{t} is COMPLETE but has no `### {t}` proof-log entry (queue or PROOF_LOG.md)"))

    # ---- Check 2: progression pointer is orchestrator-owned --------------
    base_ptr = q.parse_pointer(base_text)
    head_ptr = q.parse_pointer(head_text)
    if base_ptr != head_ptr:
        findings.append(Finding(
            "WARN", "progression",
            f"recommended-next pointer changed by this commit ({base_ptr} -> {head_ptr}); "
            f"queue progression is orchestrator-owned (run tools/next_task.py and let Opus set it)",
        ))
    else:
        findings.append(Finding("PASS", "progression", "executor did not change the recommended-next pointer"))

    # ---- Check 3: scope lint (changed code ⊆ plan Target Files) ----------
    plan_dir = head_rows.get(task, {}).get("plan_dir", "").rstrip("/")
    if not plan_dir and "/" in queue_path:
        candidate_plan_dir = queue_path.rsplit("/", 1)[0] + "/" + task
        if q.git_show(head, f"{candidate_plan_dir}/IMPLEMENTATION_PLAN.md") is not None:
            plan_dir = candidate_plan_dir
    targets: set[str] = set()
    if plan_dir:
        targets = extract_paths(q.git_show(head, f"{plan_dir}/IMPLEMENTATION_PLAN.md") or "")
    changed_code = diff_name_only(base, head, *CODE_ROOTS)
    uncovered = [c for c in changed_code if not covered(c, targets)] if targets else []
    if not targets:
        findings.append(Finding("WARN", "scope",
                                f"no Target Files parsed from {plan_dir}/IMPLEMENTATION_PLAN.md; cannot scope-lint"))
    elif uncovered:
        findings.append(Finding("WARN", "scope",
                                "changed source files not declared in plan Target Files: " + ", ".join(uncovered)))
    else:
        findings.append(Finding("PASS", "scope",
                                f"all {len(changed_code)} changed source files are within declared Target Files"))

    # ---- Check 4: tests added when acceptance requires them --------------
    row = head_rows.get(task, {})
    # The test-delivery signal is the queue's `/tests` convention in the target-files
    # cell (also "tests are recorded" in acceptance). Match "tests" (plural) so the
    # `docs/TEST.md` filename and "no analog test" negations don't trip a docs task.
    blob = " ".join([row.get("deliverable", ""), row.get("target_files", ""),
                     row.get("acceptance", "")]).lower()
    test_required = "tests" in blob and "no analog test" not in blob
    added_test_lines = diff_added_lines(base, head, *TEST_ROOTS)
    assert_adds = [ln for ln in added_test_lines
                   if re.search(r"_assert|\bfunc _test", ln) or task in ln]
    if test_required and not assert_adds:
        findings.append(Finding("FAIL", "tests",
                                "acceptance lists tests but the diff adds no test assertions / test functions"))
    elif test_required:
        findings.append(Finding("PASS", "tests", f"added {len(assert_adds)} test assertion/function lines"))
    else:
        findings.append(Finding("WARN", "tests", "acceptance does not explicitly require tests; skipped"))

    # ---- Check 5: self-review exists & is file-accurate -----------------
    sr_candidates = [f for f in q.list_files(head)
                     if re.search(rf"docs/review/autopilot/{re.escape(task)}_SELF_REVIEW.*\.md$", f)]
    if not sr_candidates:
        findings.append(Finding("FAIL", "self-review",
                                f"no self-review found at docs/review/autopilot/{task}_SELF_REVIEW_*.md"))
    else:
        sr_text = q.git_show(head, sr_candidates[0]) or ""
        unmentioned = [c for c in changed_code
                       if c.rsplit("/", 1)[-1] not in sr_text and c not in sr_text]
        if unmentioned:
            findings.append(Finding("WARN", "self-review",
                                    "changed source files not mentioned in self-review: " + ", ".join(unmentioned)))
        else:
            findings.append(Finding("PASS", "self-review",
                                    f"self-review {sr_candidates[0].rsplit('/', 1)[-1]} mentions all changed source files"))

    # ---- Report ----------------------------------------------------------
    icon = {"PASS": "✅", "WARN": "⚠️ ", "FAIL": "❌"}
    print(f"Task        : {task}")
    print(f"Range       : {q.rev_parse(base)}..{q.rev_parse(head)}")
    print(f"Queue       : {queue_path}")
    print(f"Plan dir    : {plan_dir or '(unknown)'}")
    print("-" * 72)
    for f in findings:
        print(f"{icon[f.level]} [{f.check}] {f.message}")
    print("-" * 72)
    fails = sum(1 for f in findings if f.level == "FAIL")
    warns = sum(1 for f in findings if f.level == "WARN")
    print(f"Verdict: {'REJECT' if fails else 'ACCEPT'}  ({fails} fail, {warns} warn)")
    if fails:
        print("→ Executor may NOT mark this task COMPLETE. Send findings back for repair.")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
