# PERF-60 Generate / Global Update Performance Profile Implementation Plan

Date: 2026-06-08

## Target files

- `docs/review/roadmap/GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Steps

1. Inspect Generate Dock, document apply, layer stack apply, tile redraw, and validation source paths.
2. Run a lightweight headless timing script for representative map sizes and operations.
3. Write the profile report with heavy-operation classification, freeze-cause attribution, and prioritized improvement candidates.
4. Run `./tools/test.sh`, self-review, repair any `repair-now` item, and update queue proof.
