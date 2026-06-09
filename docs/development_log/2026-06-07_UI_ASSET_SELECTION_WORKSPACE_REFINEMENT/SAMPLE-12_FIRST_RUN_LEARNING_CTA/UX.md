# SAMPLE-12 UX

## User Goal

A first-time user sees one clear learning path for bundled samples without samples becoming the default production workflow.

## Operation Steps

1. On first workspace display, a compact `Learn with bundled samples` CTA is visible above the workspace tabs.
2. Activating the CTA opens the `Settings` tab where sample controls live.
3. Dismissing the CTA hides it and leaves the workspace on the normal project asset selection path.

## Adopted UX

- The CTA is one-time session state, not a production mode switch.
- The CTA does not enable bundled samples in main selectors.
- The CTA routes to Settings / Samples instead of placing sample controls on Generate or Paint.

## Deferred UX

- Persistent editor preference storage is deferred to a later onboarding-settings task if needed.
- Rich onboarding copy and screenshots are deferred.
