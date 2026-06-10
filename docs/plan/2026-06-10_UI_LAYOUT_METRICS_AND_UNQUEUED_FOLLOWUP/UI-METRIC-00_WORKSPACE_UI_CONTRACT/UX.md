# UI-METRIC-00 UX

## User Goal

Future UI work should be judged against a clear Workspace contract: each tab has a user purpose, required components, forbidden visible text, and metric thresholds before tests or redesigns start enforcing them.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Copy old UI-00 contract docs unchanged | medium | medium | low | reject | Existing docs are useful but split across files and lack metric threshold table shape. |
| B. Consolidate into `docs/ui/WORKSPACE_UI_CONTRACT.md` | high | low | medium | adopt | Later metric tasks need one source of truth. |
| C. Define only global rules, not per-tab rules | low | high | low | reject | Tab-level components and forbidden text are required for snapshot evaluation. |
| D. Define pixel-perfect visual design | low | high | high | reject | UI metric tests should detect structural failure, not aesthetic taste. |
| E. Define named thresholds without implementing enforcement | high | low | low | adopt | Enforcement belongs to later tasks but needs stable names now. |

## Adopted UX

- Each tab has purpose, required components, forbidden visible text, metric thresholds, primary actions, and state source.
- Cross-cutting contracts define Resource rows, buttons/actions, debug/report separation, and sample learning boundaries.
- Thresholds are named and numeric where useful, but remain contract values until evaluator tasks implement them.

## Deferred UX

- State scenario expectations move to `UI-METRIC-01`.
- Static and runtime metric collection move to `UI-METRIC-02` and `UI-METRIC-03`.
- Actual visual redesign remains with later screen tasks.

## Experience Steps

1. A future UI task changes a Workspace tab.
2. The task checks the tab contract in `WORKSPACE_UI_CONTRACT.md`.
3. The task's self-review points to required components, forbidden text, and thresholds.
4. Later metric tests evaluate snapshots against the same contract.

## Existing UX Interference

The contract must not preserve old debug/path/raw/numeric fallback UI as normal workflow. If current UI still exposes one of those risks, the contract marks it as forbidden and later metric/repair tasks handle enforcement.
