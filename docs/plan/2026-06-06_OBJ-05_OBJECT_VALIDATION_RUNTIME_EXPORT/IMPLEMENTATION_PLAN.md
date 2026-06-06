# OBJ-05 Object Validation Runtime Export Implementation Plan

作成日: 2026-06-07

## Scope

- Add object scene missing and duplicate unique validation rules.
- Extend adapter tests for missing scene, object-on-wall continuity, duplicate unique detection, and passing cases.
- Add runtime object export helper to `examples/basic_runtime/runtime_query_sample.gd`.
- Extend debug/runtime sample tests for export copy behavior and authoring/runtime separation.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write test result and self-review, then update queue proof.

## Test Path

- `tests/test_hex_adapter.gd`
- `tests/test_debug_scenes.gd`
- `./tools/test.sh`

## Repair Policy

Validation false positives for legacy documents, missing object-on-wall coverage, or runtime export mutating authoring state are `repair-now`.
