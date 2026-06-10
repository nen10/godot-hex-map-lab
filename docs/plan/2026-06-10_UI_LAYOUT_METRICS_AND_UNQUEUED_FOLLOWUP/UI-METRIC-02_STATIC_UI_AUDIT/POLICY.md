# UI-METRIC-02 Policy

## Adopted Decisions

- Static audit is report-only by default.
- Findings are heuristic and must include enough location detail to inspect manually.
- The tool scans `addons/hex_map_kit/editor` by default.
- `docs/TEST.md` documents the command but `tools/test.sh` does not run it yet.

## Rejected Decisions

- Do not make static findings fail standard tests in this task.
- Do not replace runtime layout snapshot with static audit.
- Do not suppress categories just because current code may produce findings.

## Invariants

- Static audit categories match `WORKSPACE_UI_CONTRACT.md` risk classes.
- Findings are deterministic for the same source tree.
- Default command exits 0; `--strict` exits 1 when findings exist.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Heuristic false positives | allow as warnings | Static scan cannot prove visibility or runtime wiring. | Later gates tune severity and allowlists if needed. | Run tool and inspect report. |
| Debug/raw text findings | report | Debug leakage is a known first-impression risk. | Later metric gates distinguish normal UI from debug report. | `UI-METRIC-05`. |
| Generic ResourcePicker findings | report | Concrete type filters are required for production rows. | Later gates can fail required generic pickers. | `UI-METRIC-05`. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Default audit run | Returns report and exit 0. | Heuristic findings block current queue too early. | Command output plus self-review. |
| Strict audit run | Returns nonzero when findings exist. | Tool cannot be used in future gates. | `--strict` option. |
| Source scan | Detects requested categories. | Missing category leaves contract risk invisible. | Manual command output and self-review. |

## Resource / API / UI Boundary

- This task adds tooling and docs only.
- Product Resource APIs and UI behavior are unchanged.
