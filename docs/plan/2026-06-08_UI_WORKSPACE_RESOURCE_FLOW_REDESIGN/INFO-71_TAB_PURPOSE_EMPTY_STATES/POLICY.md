# INFO-71 Tab Purpose Empty States Policy

Date: 2026-06-08

## Decisions

- Empty-state copy belongs to the tab snapshot/visible status layer so UI and tests share the same contract.
- Each visible empty state must have one or two next actions.
- Production tabs must route missing resources to project asset selection or creation, not bundled sample fallback.
- Detailed explanation belongs in tooltip/help text, not primary labels.

## Non-goals

- Do not add an analog test.
- Do not reintroduce sample defaults for Generate, Paint, Validate, QA, or Export.
- Do not add large instructional copy to the tab body.
