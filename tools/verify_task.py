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

Usage:
  python3 tools/verify_task.py --task PROFILE-NEXT-10
  python3 tools/verify_task.py --task PROFILE-NEXT-10 --head agent-2 --base agent-2~1

Defaults: --head HEAD, --base <head>~1 (one commit per task, per the commit
policy). Override --base for multi-commit tasks.

Exit code 0 = no FAIL findings (WARN allowed). Exit code 1 = at least one FAIL.
Stdlib only; no third-party dependencies.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys

KNOWN_STATUSES = {
    "READY",
    "RUNNING",
    "COMPLETE",
    "BACKLOG",
    "DEFERRED",
    "BLOCKED_BY_TEST_ENV",
}
TASK_ID_RE = re.compile(r"^[A-Z0-9]+(?:-[A-Z0-9]+)+$")
# Source roots that count as "code" for scope / test checks. Planning artifacts
# (docs/plan, docs/review) are expected to change and are excluded.
CODE_ROOTS = ("addons/", "tests/", "tools/", "scripts/")
TEST_ROOTS = ("tests/",)


class Finding:
    def __init__(self, level: str, check: str, message: str):
        self.level = level  # PASS | WARN | FAIL
        self.check = check
        self.message = message


def git(*args: str) -> str:
    res = subprocess.run(
        ["git", *args], capture_output=True, text=True
    )
    return res.stdout


def git_show(ref: str, path: str) -> str | None:
    res = subprocess.run(
        ["git", "show", f"{ref}:{path}"], capture_output=True, text=True
    )
    if res.returncode != 0:
        return None
    return res.stdout


def rev_parse(ref: str) -> str:
    return git("rev-parse", "--short", ref).strip()


def list_files(ref: str) -> list[str]:
    out = git("ls-tree", "-r", "--name-only", ref)
    return [line for line in out.splitlines() if line]


def parse_queue_rows(text: str) -> dict[str, dict]:
    """Return {task_id: {status, plan_dir, deliverable, acceptance}} from a queue table."""
    rows: dict[str, dict] = {}
    for line in text.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue

        def unbacktick(cell: str) -> str:
            m = re.search(r"`([^`]+)`", cell)
            return m.group(1).strip() if m else cell.strip()

        task = unbacktick(cells[0])
        status = unbacktick(cells[1])
        if not TASK_ID_RE.match(task):
            continue
        if status not in KNOWN_STATUSES:
            continue
        rows[task] = {
            "status": status,
            "plan_dir": unbacktick(cells[3]) if len(cells) > 3 else "",
            "deliverable": cells[5] if len(cells) > 5 else "",
            "target_files": cells[6] if len(cells) > 6 else "",
            "acceptance": cells[7] if len(cells) > 7 else "",
        }
    return rows


def find_queue_path(ref: str, task: str) -> str | None:
    candidates = [
        f for f in list_files(ref) if f.endswith("IMPLEMENTATION_QUEUE.md")
    ]
    best = None
    best_count = -1
    for path in candidates:
        text = git_show(ref, path) or ""
        rows = parse_queue_rows(text)
        if task in rows and len(rows) > best_count:
            best = path
            best_count = len(rows)
    return best


def extract_paths(text: str) -> set[str]:
    """Pull file-path-looking tokens out of a markdown doc."""
    paths: set[str] = set()
    for m in re.finditer(r"`([^`]+)`", text):
        tok = m.group(1).strip()
        if "/" in tok and re.search(r"\.\w+$", tok):
            paths.add(tok)
    # also bare paths under known roots
    for m in re.finditer(r"(?:addons|tests|tools|scripts)/[\w./-]+\.\w+", text):
        paths.add(m.group(0))
    return paths


def diff_name_only(base: str, head: str, *paths: str) -> list[str]:
    out = git("diff", "--name-only", f"{base}", f"{head}", "--", *paths)
    return [line for line in out.splitlines() if line]


def diff_added_lines(base: str, head: str, *paths: str) -> list[str]:
    out = git("diff", f"{base}", f"{head}", "--", *paths)
    added = []
    for line in out.splitlines():
        if line.startswith("+") and not line.startswith("+++"):
            added.append(line[1:])
    return added


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

    queue_path = args.queue or find_queue_path(head, task)
    if not queue_path:
        print(f"FAIL: could not locate an IMPLEMENTATION_QUEUE.md containing `{task}` at {head}")
        return 1

    head_rows = parse_queue_rows(git_show(head, queue_path) or "")
    base_rows = parse_queue_rows(git_show(base, queue_path) or "")
    head_queue_text = git_show(head, queue_path) or ""

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
        findings.append(Finding(
            "PASS", "queue-integrity",
            f"only assigned task status changed to COMPLETE",
        ))

    if head_rows.get(task, {}).get("status") != "COMPLETE":
        findings.append(Finding(
            "WARN", "assigned-status",
            f"{task} is not COMPLETE at {head} (status={head_rows.get(task, {}).get('status')})",
        ))

    # proof-log entry for every newly-complete task
    for t in newly_complete:
        if not re.search(rf"^###\s+{re.escape(t)}\b", head_queue_text, re.MULTILINE):
            findings.append(Finding(
                "FAIL", "proof-log",
                f"{t} is COMPLETE but has no `### {t}` proof-log entry in the queue",
            ))

    # ---- Check 2: scope lint (changed code ⊆ plan Target Files) ----------
    plan_dir = head_rows.get(task, {}).get("plan_dir", "").rstrip("/")
    targets: set[str] = set()
    if plan_dir:
        plan_text = git_show(head, f"{plan_dir}/IMPLEMENTATION_PLAN.md") or ""
        targets = extract_paths(plan_text)
    changed_code = diff_name_only(base, head, *CODE_ROOTS)
    uncovered = [c for c in changed_code if not covered(c, targets)] if targets else []
    if not targets:
        findings.append(Finding(
            "WARN", "scope",
            f"no Target Files parsed from {plan_dir}/IMPLEMENTATION_PLAN.md; cannot scope-lint",
        ))
    elif uncovered:
        findings.append(Finding(
            "WARN", "scope",
            "changed source files not declared in plan Target Files: " + ", ".join(uncovered),
        ))
    else:
        findings.append(Finding(
            "PASS", "scope",
            f"all {len(changed_code)} changed source files are within declared Target Files",
        ))

    # ---- Check 3: tests added when acceptance requires them --------------
    row = head_rows.get(task, {})
    acceptance_blob = (row.get("deliverable", "") + " " + row.get("acceptance", "")).lower()
    test_required = "test" in acceptance_blob
    added_test_lines = diff_added_lines(base, head, *TEST_ROOTS)
    assert_adds = [
        ln for ln in added_test_lines
        if re.search(r"_assert|\bfunc _test", ln) or task in ln
    ]
    if test_required and not assert_adds:
        findings.append(Finding(
            "FAIL", "tests",
            "acceptance lists tests but the diff adds no test assertions / test functions",
        ))
    elif test_required:
        findings.append(Finding(
            "PASS", "tests",
            f"added {len(assert_adds)} test assertion/function lines",
        ))
    else:
        findings.append(Finding(
            "WARN", "tests",
            "acceptance does not explicitly require tests; skipped",
        ))

    # ---- Check 4: self-review exists & is file-accurate -----------------
    sr_candidates = [
        f for f in list_files(head)
        if re.search(rf"docs/review/autopilot/{re.escape(task)}_SELF_REVIEW.*\.md$", f)
    ]
    if not sr_candidates:
        findings.append(Finding(
            "FAIL", "self-review",
            f"no self-review found at docs/review/autopilot/{task}_SELF_REVIEW_*.md",
        ))
    else:
        sr_text = git_show(head, sr_candidates[0]) or ""
        unmentioned = [
            c for c in changed_code
            if c.rsplit("/", 1)[-1] not in sr_text and c not in sr_text
        ]
        if unmentioned:
            findings.append(Finding(
                "WARN", "self-review",
                "changed source files not mentioned in self-review: " + ", ".join(unmentioned),
            ))
        else:
            findings.append(Finding(
                "PASS", "self-review",
                f"self-review {sr_candidates[0].rsplit('/', 1)[-1]} mentions all changed source files",
            ))

    # ---- Report ----------------------------------------------------------
    icon = {"PASS": "✅", "WARN": "⚠️ ", "FAIL": "❌"}
    print(f"Task        : {task}")
    print(f"Range       : {rev_parse(base)}..{rev_parse(head)}")
    print(f"Queue       : {queue_path}")
    print(f"Plan dir    : {plan_dir or '(unknown)'}")
    print("-" * 72)
    for f in findings:
        print(f"{icon[f.level]} [{f.check}] {f.message}")
    print("-" * 72)
    fails = sum(1 for f in findings if f.level == "FAIL")
    warns = sum(1 for f in findings if f.level == "WARN")
    verdict = "REJECT" if fails else "ACCEPT"
    print(f"Verdict: {verdict}  ({fails} fail, {warns} warn)")
    if fails:
        print("→ Executor may NOT mark this task COMPLETE. Send findings back for repair.")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
