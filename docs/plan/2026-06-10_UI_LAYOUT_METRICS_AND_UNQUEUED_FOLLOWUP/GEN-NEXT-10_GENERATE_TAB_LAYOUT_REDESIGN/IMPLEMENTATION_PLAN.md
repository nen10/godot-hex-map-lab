# Implementation Plan

## Scope

Redesign the Generate tab layout into explicit work sections while preserving generation behavior and existing component builder ownership.

## Target Files

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_gen_run_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_source_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_output_controls.gd`
- `addons/hex_map_kit/editor/hex_map_gen_result_controls.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Planned Implementation Steps

1. Add Generate layout section ids and a `generation_layout_snapshot()` contract.
2. Wrap existing Generate controls into Input, Profile / Source, Preview, Apply / Save, and Performance sections.
3. Add metadata to mounted controls for layout section and action purpose where relevant.
4. Keep output target, save/apply, result summary, seed lab, and progress references wired to existing state handlers.
5. Add tests that assert required sections, component membership, purpose clarity, and workspace snapshot exposure.
6. Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Thumbnail rendering | defer | Covered by `GEN-NEXT-11`. |
| GenerationResultResource/replay API | defer | Covered by `GENPIPE-NEXT-10`. |
| Private generation flag cleanup | defer | Covered by `STATE-NEXT-11`. |
| Multi-tab Generate wizard | reject | Current acceptance needs clarity in the existing Generate tab. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Generate component builders | Metadata drift or broken ownership rows. | Existing ARCH-NEXT-11 owner tests plus section metadata assertions. |
| Output target ViewState | Preview/document/save state regression. | Existing NODE-24 tests. |
| Progress/chunked apply | Performance state disconnected from layout. | Existing PERF-NEXT-10 tests plus Performance section snapshot. |
| Workspace screen snapshot | Layout proof unavailable to UI metric/state contract. | New workspace generation snapshot assertions. |
| UI metrics | P0 visual regression. | `./tools/test.sh` metric report. |

## Docs Updates

- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with `GEN-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- Generate screen exposes required layout sections and action-purpose metadata.
- Input/Profile/Preview/Apply/Save/Performance state are visually and structurally separated.
- Reload/source browse, Save As, and Apply to Document purposes are explicit.
- Existing generation output/apply/save behavior remains green.
- `./tools/test.sh` passes with UI metric P0 failures = 0.
