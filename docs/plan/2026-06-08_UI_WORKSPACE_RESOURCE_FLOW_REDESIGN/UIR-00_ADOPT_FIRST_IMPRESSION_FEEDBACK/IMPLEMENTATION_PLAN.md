# UIR-00 Implementation Plan

## Scope

- Make the first-impression feedback adoption explicit in project policy.
- Confirm roadmap decisions for samples, `dist`, headless tests, and analog tests.
- Update the queue with completion proof and the next valid READY task.

## Change Targets

- `AGENTS.md`
- `docs/policy/IMPLEMENTATION_POLICY.md`
- `docs/policy/TEST_DESIGN_POLICY.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/ROADMAP.md`
- `docs/plan/2026-06-08_UI_WORKSPACE_RESOURCE_FLOW_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/UIR-00_SELF_REVIEW_2026-06-08.md`
- `docs/review/autopilot/UIR-00_TEST_RESULT_2026-06-08.md`

## Steps

1. Add explicit policy text for UI first impression, sample fallback, and final-only `dist` regeneration.
2. Keep roadmap status/proof aligned with the queue.
3. Run `./tools/test.sh`.
4. Record self-review and test result.
5. Sweep dependencies and promote the next valid task.
6. Commit the completed task.

## Deferred Steps

- Do not implement UI layout or resource binding changes in this task.
- Do not regenerate `dist`.
- Do not create analog tests.

## Test Path

```sh
./tools/test.sh
```

## Docs Update

The policy docs are the main deliverable. `docs/TEST.md` does not need a change unless verification policy changes beyond the existing CLEAN UI rules.

## Completion Checklist

- Sample is documented as learning / duplicate source, not execution fallback.
- Dist freshness is documented as final process, not normal test.
- UI first impression is documented as stronger completion evidence than headless API availability.
- Self-review confirms no sample-only completion proof.
