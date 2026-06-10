# UI-METRIC-03 UX

## User Goal

Codex should be able to build representative Workspace UI states at multiple sizes and inspect what a user would actually see, without treating the current output as a pass/fail gate yet.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Runtime visible Control snapshot | high | low | medium | adopt | It captures actual visibility, text, rects, and scroll ancestry. |
| B. Static-only source scan | medium | medium | low | reject | Static audit already exists and cannot prove runtime layout. |
| C. Single default viewport | medium | medium | low | reject | Layout regressions appear at smaller sizes. |
| D. Multiple scenario and viewport matrix | high | low | medium | adopt | It connects to the state matrix and first-impression layout contract. |
| E. Immediate red/green UX scoring | medium | high | high | reject | Metric severity tuning belongs to later queue tasks. |

## Adopted UX

- A test helper builds Workspace states for no selected HexTileMap, selected HexTileMap without resources, and selected HexTileMap with shared resources.
- The snapshot collector records visible controls and enough fields to support later metric evaluation.
- The test asserts snapshot structure, JSON serialization, scroll ancestry, and multi-size scenario coverage.

## Deferred UX

- Human-readable metric reports and WARN/P0/P1 scoring remain in `UI-METRIC-04` through `UI-METRIC-07`.
- Screenshot or pixel-based visual comparison remains out of this collector slice.

## Experience Steps

1. Run standard tests.
2. The layout metrics test creates Workspace scenarios at multiple viewport sizes.
3. The collector walks visible Controls and serializes a JSON snapshot.
4. Later metric tasks evaluate the captured fields against the UI contract.

## Existing UX Interference

This task must not turn current UI issues into blockers. It creates the measurement surface so later tasks can classify and repair those issues explicitly.
