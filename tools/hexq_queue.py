"""Shared parsing for the Hex Map Kit implementation queue.

Used by `tools/verify_task.py` (completion gate) and `tools/next_task.py`
(progression scheduler). Stdlib only.

The queue is a markdown file with task rows shaped like:

    | `TASK-ID` | `STATUS` | `dep, dep` | `plan_dir` | deliverable | target files | acceptance |

and a pointer line `Current recommended next task: `TASK-ID``.
"""

from __future__ import annotations

import re
import subprocess

KNOWN_STATUSES = {
    "READY",
    "RUNNING",
    "COMPLETE",
    "BACKLOG",
    "DEFERRED",
    "BLOCKED_BY_TEST_ENV",
}
TASK_ID_RE = re.compile(r"^[A-Z0-9]+(?:-[A-Z0-9]+)+$")
POINTER_RE = re.compile(r"Current recommended next task:\s*`([^`]+)`")


def git(*args: str) -> str:
    return subprocess.run(["git", *args], capture_output=True, text=True).stdout


def git_show(ref: str, path: str) -> str | None:
    res = subprocess.run(
        ["git", "show", f"{ref}:{path}"], capture_output=True, text=True
    )
    return res.stdout if res.returncode == 0 else None


def rev_parse(ref: str) -> str:
    return git("rev-parse", "--short", ref).strip()


def list_files(ref: str) -> list[str]:
    return [ln for ln in git("ls-tree", "-r", "--name-only", ref).splitlines() if ln]


def read_text(path: str, ref: str | None = None) -> str | None:
    """Read a file from a git ref, or from the working tree if ref is None."""
    if ref:
        return git_show(ref, path)
    try:
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    except OSError:
        return None


def _unbacktick(cell: str) -> str:
    m = re.search(r"`([^`]+)`", cell)
    return m.group(1).strip() if m else cell.strip()


def _split_deps(cell: str) -> list[str]:
    deps: list[str] = []
    for m in re.finditer(r"`([^`]+)`", cell):
        dep = m.group(1).strip()
        if TASK_ID_RE.match(dep):
            deps.append(dep)
    return deps


def parse_queue_rows(text: str) -> dict[str, dict]:
    """Return {task_id: {status, dependencies, plan_dir, deliverable, target_files, acceptance, order}}."""
    rows: dict[str, dict] = {}
    order = 0
    for line in text.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        task = _unbacktick(cells[0])
        status = _unbacktick(cells[1])
        if not TASK_ID_RE.match(task) or status not in KNOWN_STATUSES:
            continue
        rows[task] = {
            "status": status,
            "dependencies": _split_deps(cells[2]) if len(cells) > 2 else [],
            "plan_dir": _unbacktick(cells[3]) if len(cells) > 3 else "",
            "deliverable": cells[4] if len(cells) > 4 else "",
            "target_files": cells[5] if len(cells) > 5 else "",
            "acceptance": cells[6] if len(cells) > 6 else "",
            "order": order,
        }
        order += 1
    return rows


def parse_pointer(text: str) -> str | None:
    m = POINTER_RE.search(text)
    return m.group(1).strip() if m else None


def find_queue_path(ref: str | None, task: str | None = None) -> str | None:
    """Find the active queue. With `task`, the one containing that task row.

    Without `task`, the queue that has a recommended-next pointer and the most
    task rows (i.e. the active roadmap queue, not an archived one).
    """
    if ref:
        candidates = [f for f in list_files(ref) if f.endswith("IMPLEMENTATION_QUEUE.md")]
    else:
        import glob
        candidates = glob.glob("docs/**/IMPLEMENTATION_QUEUE.md", recursive=True)
    best = None
    best_score = (-1, -1)
    for path in candidates:
        text = read_text(path, ref) or ""
        rows = parse_queue_rows(text)
        if task and task not in rows:
            continue
        has_pointer = 1 if parse_pointer(text) else 0
        score = (has_pointer, len(rows))
        if score > best_score:
            best, best_score = path, score
    return best


def deps_satisfied(rows: dict[str, dict], task: str) -> tuple[bool, list[str]]:
    """Is every dependency COMPLETE? Returns (ok, unmet_deps)."""
    unmet = [
        d for d in rows.get(task, {}).get("dependencies", [])
        if rows.get(d, {}).get("status") != "COMPLETE"
    ]
    return (not unmet, unmet)


def reverse_deps(rows: dict[str, dict]) -> dict[str, list[str]]:
    """task -> list of tasks that depend on it (unlock impact)."""
    rev: dict[str, list[str]] = {t: [] for t in rows}
    for t, r in rows.items():
        for d in r["dependencies"]:
            rev.setdefault(d, []).append(t)
    return rev
