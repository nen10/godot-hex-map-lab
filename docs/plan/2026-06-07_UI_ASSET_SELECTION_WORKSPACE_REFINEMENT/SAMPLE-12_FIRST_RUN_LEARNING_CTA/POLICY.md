# SAMPLE-12 Policy

## Adopted Decisions

- First-run CTA visibility is represented in `HexMapEditorSessionState`.
- CTA activation selects the existing Settings tab; sample settings remain the only sample control surface.
- CTA dismissal hides the banner without changing sample-mode flags.
- Tests verify state and routing, not private widget names.

## Rejected Decisions

- Do not enable sample mode when the CTA is clicked.
- Do not assign sample assets to workspace context from the CTA.
- Do not write global editor preferences from the headless test path.

## Boundary

- This task adds the first-run CTA contract only.
- Persistent cross-session onboarding state and richer conflict/onboarding UX remain out of scope.
