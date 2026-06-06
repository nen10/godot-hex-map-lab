# QA-04 Golden Seed Fixtures UX

Task: `QA-04`  
Created: 2026-06-07  
Status: RUNNING

## Goal

Give generation QA a small set of stable, human-readable golden seeds that catch unintended generator output drift without requiring visual screenshots.

## Operation Steps

1. Codex selects important generator scenarios that represent normal rectangle generation and symmetric toric generation.
2. Each scenario records deterministic parameters, score metrics, wall keys, and ASCII preview rows.
3. Automated tests regenerate each seed and compare the fixture to the current generator output.
4. A reviewer can inspect the JSON fixture preview rows when a test fails to understand the changed map shape.

## Non-goals

- No screenshot or visual assertion requirement.
- No editor UI changes.
- No seed approval workflow; this task creates the test fixture foundation only.

