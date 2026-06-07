# SAMPLE-10 UX

## User Goal

Bundled samples are learning assets managed from Settings / Samples, not hidden defaults in the main production selectors.

## Operation Steps

1. The workspace exposes a Settings tab with a Samples panel.
2. Sample visibility in main asset selectors is OFF by default for workspace sessions.
3. The user may turn sample visibility ON from Settings / Samples.
4. Even when sample visibility is ON, an explicitly selected project asset in workspace context remains primary.

## Adopted UX

- Settings / Samples owns bundled sample catalog, tiles, and object scene references.
- Generate/Paint selector fallback does not load bundled sample catalog when sample visibility is OFF.
- Direct project context selection takes precedence over bundled samples.

## Deferred UX

- Duplicating samples to project assets is deferred to `SAMPLE-11`.
- First-run learning CTA is deferred to `SAMPLE-12`.
- Full tab migration remains `WORKSPACE-10`.
