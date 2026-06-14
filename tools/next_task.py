#!/usr/bin/env python3
"""Queue progression scheduler — the Opus-owned task-selection step.

Per `docs/process/AGENT_ROSTER_AND_ROUTING.md`, deciding *which task runs next*
belongs to the orchestrator (Opus), not the executor agent. This tool makes that
decision reliable instead of hand-parsed: it computes the eligible frontier from
real dependency math, surfaces tasks that just became unblocked, flags queue
inconsistencies, and suggests routing/depth. The *decision* still stays with
Opus — the hints are advisory.

Read-only by default:
    python3 tools/next_task.py

Act on the queue (Opus only; dry-run unless --apply):
    python3 tools/next_task.py --set STATE-NEXT-11 --apply        # set the pointer
    python3 tools/next_task.py --promote --apply                  # BACKLOG->READY for unblocked

Stdlib only. Reads the working tree by default (use --head <ref> to inspect a ref).
"""

from __future__ import annotations

import argparse
import re
import sys

import hexq_queue as q

# Heuristic keyword maps. These only *suggest*; Opus sets the final route/depth.
ROUTE_EXPLORE = ("research", "spike", "decision", "redesign", "prototype", "graph",
                 "polish", "affordance", "drawer", "thumbnail", "visual", "explore")
ROUTE_CODEX = ("extraction", "split", "schema", "typed", "gate", "test", "refactor",
               "reducer", "retirement", "integration", "progress", "service", "wiring")
DEPTH_DECISION = ("research", "spike", "decision")
DEPTH_INTEGRATED = ("integration", "wire", "wiring", "engine", "runtime", "behavior",
                    "extraction", "retirement", "reducer", "apply", "progress")
DEPTH_SURFACE = ("schema", "exposure", "screen", "redesign", "label", "styling",
                 "drawer", "thumbnail", "preview")


def _blob(row: dict) -> str:
    return (row.get("deliverable", "") + " " + row.get("acceptance", "")).lower()


def route_hint(row: dict) -> str:
    blob = _blob(row)
    if any(k in blob for k in ROUTE_EXPLORE):
        return "DeepSeek (or dual-run)"
    if any(k in blob for k in ROUTE_CODEX):
        return "Codex"
    return "Codex"


def depth_hint(row: dict) -> str:
    blob = _blob(row)
    if any(k in blob for k in DEPTH_DECISION):
        return "decision"
    if any(k in blob for k in DEPTH_INTEGRATED):
        return "integrated"
    if any(k in blob for k in DEPTH_SURFACE):
        return "surface"
    return "?"


def _trunc(s: str, n: int = 64) -> str:
    s = re.sub(r"\s+", " ", s).strip()
    return s if len(s) <= n else s[: n - 1] + "…"


def set_pointer(text: str, task: str) -> str:
    return q.POINTER_RE.sub(f"Current recommended next task: `{task}`", text, count=1)


def promote_row(text: str, task: str, new_status: str = "READY") -> str:
    # Only the row whose ID cell (first data cell) IS the task — never a row that
    # merely lists the task as a dependency (that would corrupt the dependent row's
    # plan-dir cell). cells = ["", " `ID` ", " `STATUS` ", ...].
    out = []
    for line in text.splitlines():
        cells = line.split("|")
        if len(cells) > 2 and q._unbacktick(cells[1]) == task:
            cells[2] = re.sub(r"`[^`]+`", f"`{new_status}`", cells[2], count=1)
            line = "|".join(cells)
        out.append(line)
    return "\n".join(out) + ("\n" if text.endswith("\n") else "")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--head", default=None, help="git ref to read (default: working tree)")
    ap.add_argument("--queue", default=None, help="queue path override")
    ap.add_argument("--set", dest="set_task", default=None, help="set recommended-next pointer to this task id")
    ap.add_argument("--promote", action="store_true", help="flip newly-unblocked BACKLOG/DEFERRED tasks to READY")
    ap.add_argument("--apply", action="store_true", help="write changes (default: dry-run)")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    args = ap.parse_args()

    queue_path = args.queue or q.find_queue_path(args.head)
    if not queue_path:
        print("FAIL: no active IMPLEMENTATION_QUEUE.md found")
        return 1
    text = q.read_text(queue_path, args.head) or ""
    rows = q.parse_queue_rows(text)
    pointer = q.parse_pointer(text)
    rev = q.reverse_deps(rows)

    def unlock_count(task: str) -> int:
        # how many not-yet-complete tasks depend on this one
        return sum(1 for t in rev.get(task, []) if rows.get(t, {}).get("status") != "COMPLETE")

    eligible, newly_unblocked, blocked_ready, running = [], [], [], []
    for t, r in rows.items():
        ok, unmet = q.deps_satisfied(rows, t)
        st = r["status"]
        if st == "RUNNING":
            running.append(t)
        elif st == "READY" and ok:
            eligible.append(t)
        elif st == "READY" and not ok:
            blocked_ready.append((t, unmet))
        elif st in ("BACKLOG", "DEFERRED") and ok:
            newly_unblocked.append(t)

    eligible.sort(key=lambda t: (-unlock_count(t), rows[t]["order"]))
    newly_unblocked.sort(key=lambda t: (-unlock_count(t), rows[t]["order"]))

    # ---- mutations (Opus-owned actions) ----
    if args.set_task or args.promote:
        if args.head:
            print("FAIL: --set/--promote operate on the working tree; do not pass --head")
            return 1
        new_text = text
        changes = []
        if args.promote:
            for t in newly_unblocked:
                new_text = promote_row(new_text, t, "READY")
                changes.append(f"promote {t}: {rows[t]['status']} -> READY")
        if args.set_task:
            if args.set_task not in rows:
                print(f"FAIL: --set target {args.set_task} is not a task in the queue")
                return 1
            new_text = set_pointer(new_text, args.set_task)
            changes.append(f"pointer: {pointer} -> {args.set_task}")
        print("Planned queue changes:")
        for c in changes:
            print(f"  - {c}")
        if args.apply:
            with open(queue_path, "w", encoding="utf-8") as fh:
                fh.write(new_text)
            print(f"APPLIED to {queue_path}")
        else:
            print("(dry-run; re-run with --apply to write)")
        return 0

    # ---- advisory report ----
    if args.json:
        import json
        print(json.dumps({
            "queue": queue_path,
            "pointer": pointer,
            "eligible": [{"id": t, "unlocks": unlock_count(t), "route_hint": route_hint(rows[t]),
                          "depth_hint": depth_hint(rows[t]), "deps": rows[t]["dependencies"]} for t in eligible],
            "newly_unblocked": newly_unblocked,
            "blocked_ready": [{"id": t, "unmet": u} for t, u in blocked_ready],
            "running": running,
        }, indent=2))
        return 0

    print(f"Queue   : {queue_path}")
    print(f"Pointer : {pointer or '(none)'}")
    print("=" * 78)
    print("ELIGIBLE NOW  (status READY + all deps COMPLETE) — pick one, set depth, route:")
    if not eligible:
        print("  (none)")
    for t in eligible:
        r = rows[t]
        star = " ★pointer" if t == pointer else ""
        print(f"  • {t}  [unlocks {unlock_count(t)}]  route≈{route_hint(r)}  depth≈{depth_hint(r)}{star}")
        print(f"      {_trunc(r['deliverable'], 72)}")
    print("-" * 78)
    print("NEWLY UNBLOCKED  (deps now COMPLETE but still BACKLOG/DEFERRED — promote?):")
    if not newly_unblocked:
        print("  (none)")
    for t in newly_unblocked:
        print(f"  • {t}  ({rows[t]['status']})  [unlocks {unlock_count(t)}]  — `next_task.py --promote --apply`")
    if blocked_ready:
        print("-" * 78)
        print("INCONSISTENT  (marked READY but deps unmet — queue bug):")
        for t, unmet in blocked_ready:
            print(f"  • {t}  waiting on: {', '.join(unmet)}")
    if running:
        print("-" * 78)
        print("RUNNING:", ", ".join(running))
    print("=" * 78)
    rec = eligible[0] if eligible else None
    if rec:
        consistent = "matches pointer" if rec == pointer else f"differs from pointer ({pointer})"
        print(f"Recommended start: {rec}  ({consistent})")
        print("Opus decides: confirm the task, set depth (surface|integrated|decision), route, then write the contract.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
