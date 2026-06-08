# PERF-60 Generate / Global Update Performance Policy

Date: 2026-06-08

## Decisions

- This task classifies performance risks and improvement candidates. It does not add busy UI or debounce behavior.
- Evidence should combine source-path inspection with lightweight headless timing.
- UI freeze causes must be labeled as generation, apply/redraw, validation, or mixed.
- Follow-up implementation belongs to PERF-61 / PERF-62 unless a small correctness repair is required to complete the profile.

## Non-goals

- Do not add a new analog test.
- Do not distort UI workflow for profiling.
- Do not make sample-only timings the production proof.
