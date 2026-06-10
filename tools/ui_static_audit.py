#!/usr/bin/env python3
"""Static audit for Hex Map Kit editor UI contract risks.

The audit is intentionally heuristic. It reports likely risks for later
inspection and exits 0 by default. Use --strict to make any finding fail.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


DEFAULT_SCAN_ROOTS = ("addons/hex_map_kit/editor",)

BUTTON_NEW_RE = re.compile(r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?::=|=)\s*Button\.new\s*\(")
TEXT_ASSIGN_RE = re.compile(
    r"(?P<target>[A-Za-z_][A-Za-z0-9_]*)\.text\s*=\s*\"(?P<text>[^\"]*)\""
)
VISIBLE_TEXT_ASSIGN_RE = re.compile(
    r"(\.text|\.placeholder_text|\.default_text)\s*=|(^|\s)(text|label_text|default_text|visible_text)\s*(:=|=)"
)
EDITOR_PICKER_RE = re.compile(
    r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?::=|=)\s*EditorResourcePicker\.new\s*\("
)
FUNC_RE = re.compile(r"^func\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(")

FORBIDDEN_BUTTON_TEXT = {
    "details",
    "open",
    "select",
    "validate",
    "link",
    "node",
    "sample",
    "clear",
}

DEBUG_TEXT_PATTERNS = (
    re.compile(r"\bdebug\b", re.IGNORECASE),
    re.compile(r"\braw\b", re.IGNORECASE),
    re.compile(r"\bjson\b", re.IGNORECASE),
    re.compile(r"\bprivate\b", re.IGNORECASE),
    re.compile(r"\bfallback\b", re.IGNORECASE),
    re.compile(r"\bnode path\b", re.IGNORECASE),
    re.compile(r"\bsource id\b", re.IGNORECASE),
    re.compile(r"\batlas (source|coord)", re.IGNORECASE),
    re.compile(r"res://"),
    re.compile(r"/root/"),
    re.compile(r"@Editor"),
)


@dataclass(frozen=True)
class Finding:
    category: str
    severity: str
    path: str
    line: int
    message: str
    evidence: str


@dataclass
class ButtonRecord:
    name: str
    line: int
    text: str = ""
    text_line: int = 0
    added: bool = False
    connected: bool = False


def iter_gd_files(root: Path, scan_roots: Iterable[str]) -> Iterable[Path]:
    for scan_root in scan_roots:
        path = root / scan_root
        if path.is_file() and path.suffix == ".gd":
            yield path
        elif path.is_dir():
            yield from sorted(path.rglob("*.gd"))


def relpath(root: Path, path: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def normalized_button_text(text: str) -> str:
    return text.strip().lower().removesuffix("...").strip()


def audit_button_wiring(root: Path, path: Path, lines: list[str]) -> list[Finding]:
    records: dict[str, ButtonRecord] = {}
    findings: list[Finding] = []

    for index, line in enumerate(lines, start=1):
        match = BUTTON_NEW_RE.search(line)
        if match:
            name = match.group("name")
            records[name] = ButtonRecord(name=name, line=index)

        text_match = TEXT_ASSIGN_RE.search(line)
        if text_match:
            target = text_match.group("target")
            text = text_match.group("text")
            if target in records:
                records[target].text = text
                records[target].text_line = index
                normalized = normalized_button_text(text)
                if normalized in FORBIDDEN_BUTTON_TEXT:
                    findings.append(
                        Finding(
                            category="forbidden_button_text",
                            severity="warn",
                            path=relpath(root, path),
                            line=index,
                            message=f"Button `{target}` uses placeholder-like text `{text}`.",
                            evidence=line.strip(),
                        )
                    )

        for name, record in records.items():
            if f"{name}.pressed.connect" in line:
                record.connected = True
            if re.search(rf"\.add_child\s*\(\s*{re.escape(name)}\s*\)", line):
                record.added = True

    for record in records.values():
        if (record.added or record.text) and not record.connected:
            findings.append(
                Finding(
                    category="button_without_pressed_connection",
                    severity="warn",
                    path=relpath(root, path),
                    line=record.line,
                    message=f"Button `{record.name}` is visible or labeled but has no pressed.connect in this file.",
                    evidence=record.text or record.name,
                )
            )

    return findings


def audit_debug_text(root: Path, path: Path, lines: list[str]) -> list[Finding]:
    findings: list[Finding] = []
    for index, line in enumerate(lines, start=1):
        if not VISIBLE_TEXT_ASSIGN_RE.search(line):
            continue
        if "tooltip_text" in line:
            continue
        for pattern in DEBUG_TEXT_PATTERNS:
            if pattern.search(line):
                findings.append(
                    Finding(
                        category="visible_debug_text_pattern",
                        severity="warn",
                        path=relpath(root, path),
                        line=index,
                        message=f"Visible text assignment matches debug/internal pattern `{pattern.pattern}`.",
                        evidence=line.strip(),
                    )
                )
                break
    return findings


def audit_resource_pickers(root: Path, path: Path, lines: list[str]) -> list[Finding]:
    findings: list[Finding] = []
    for index, line in enumerate(lines, start=1):
        match = EDITOR_PICKER_RE.search(line)
        if not match:
            continue
        name = match.group("name")
        window = lines[index - 1 : min(len(lines), index + 80)]
        base_assignments = [entry.strip() for entry in window if f"{name}.base_type" in entry]
        if not base_assignments:
            findings.append(
                Finding(
                    category="generic_resource_picker",
                    severity="warn",
                    path=relpath(root, path),
                    line=index,
                    message=f"EditorResourcePicker `{name}` has no nearby base_type assignment.",
                    evidence=line.strip(),
                )
            )
            continue
        for assignment in base_assignments:
            if re.search(r"base_type\s*=\s*\"Resource\"", assignment) or '"Resource"' in assignment:
                findings.append(
                    Finding(
                        category="generic_resource_picker",
                        severity="warn",
                        path=relpath(root, path),
                        line=index,
                        message=f"EditorResourcePicker `{name}` may fall back to generic Resource base type.",
                        evidence=assignment,
                    )
                )
                break
    return findings


def function_blocks(lines: list[str]) -> Iterable[tuple[str, int, list[str]]]:
    current_name = ""
    current_start = 0
    current_body: list[str] = []
    for index, line in enumerate(lines, start=1):
        match = FUNC_RE.match(line)
        if match:
            if current_name:
                yield current_name, current_start, current_body
            current_name = match.group("name")
            current_start = index
            current_body = [line]
        elif current_name:
            current_body.append(line)
    if current_name:
        yield current_name, current_start, current_body


def audit_tab_scroll(root: Path, path: Path, lines: list[str]) -> list[Finding]:
    findings: list[Finding] = []
    if path.name != "hex_map_workspace.gd":
        return findings
    for name, start, body in function_blocks(lines):
        if name != "_add_tab_page" and not re.search(r"(tab|screen)", name):
            continue
        body_text = "\n".join(body)
        constructs_tab = "add_child" in body_text and ("tab" in name or "Tab" in body_text)
        if constructs_tab and "ScrollContainer.new" not in body_text and "_add_tab_page" in name:
            findings.append(
                Finding(
                    category="tab_without_scroll_container",
                    severity="warn",
                    path=relpath(root, path),
                    line=start,
                    message=f"Tab constructor `{name}` does not create a ScrollContainer.",
                    evidence=body[0].strip(),
                )
            )
    if not any("func _add_tab_page" in line for line in lines):
        findings.append(
            Finding(
                category="tab_without_scroll_container",
                severity="warn",
                path=relpath(root, path),
                line=1,
                message="No `_add_tab_page` constructor found for scroll container audit.",
                evidence=path.name,
            )
        )
    return findings


def audit_file(root: Path, path: Path) -> list[Finding]:
    lines = path.read_text(encoding="utf-8").splitlines()
    findings: list[Finding] = []
    findings.extend(audit_button_wiring(root, path, lines))
    findings.extend(audit_debug_text(root, path, lines))
    findings.extend(audit_resource_pickers(root, path, lines))
    findings.extend(audit_tab_scroll(root, path, lines))
    return findings


def print_text_report(findings: list[Finding]) -> None:
    print(f"UI static audit findings: {len(findings)}")
    counts: dict[str, int] = {}
    for finding in findings:
        counts[finding.category] = counts.get(finding.category, 0) + 1
    for category in sorted(counts):
        print(f"- {category}: {counts[category]}")
    if findings:
        print()
    for finding in findings:
        print(
            f"[{finding.severity.upper()}] {finding.category} "
            f"{finding.path}:{finding.line} {finding.message}"
        )
        print(f"  {finding.evidence}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Static audit for editor UI contract risks.")
    parser.add_argument(
        "paths",
        nargs="*",
        help="Files or directories to scan. Defaults to addons/hex_map_kit/editor.",
    )
    parser.add_argument("--root", default=".", help="Repository root.")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    parser.add_argument("--strict", action="store_true", help="Exit 1 when findings exist.")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    scan_roots = tuple(args.paths) if args.paths else DEFAULT_SCAN_ROOTS
    files = list(iter_gd_files(root, scan_roots))
    findings: list[Finding] = []
    for path in files:
        findings.extend(audit_file(root, path))

    findings.sort(key=lambda item: (item.path, item.line, item.category, item.message))

    if args.format == "json":
        print(json.dumps([asdict(finding) for finding in findings], indent=2, sort_keys=True))
    else:
        print_text_report(findings)

    if args.strict and findings:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
