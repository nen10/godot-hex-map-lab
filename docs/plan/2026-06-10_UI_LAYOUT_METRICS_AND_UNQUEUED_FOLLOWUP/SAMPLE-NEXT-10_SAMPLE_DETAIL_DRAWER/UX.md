# SAMPLE-NEXT-10 UX

## User Job

A developer inspects bundled sample assets to learn what they contain, where they depend on other sample files, and what duplicate-to-project action is available before using them.

## Required Visible State

| state | UX requirement |
|---|---|
| Sample asset type | Detail identifies catalog, texture, or scene. |
| Dependencies | Detail shows related bundled dependencies. |
| Duplicate target | Detail shows whether a project duplicate target is available. |
| Learning use | Detail states the sample is a learning source, not a production fallback. |

## First Impression Bar

- The Sample Learning area should expose a clear detail drawer for the selected sample row.
- The detail must not make samples look like active production assets.
- Paths remain detail/tooltip data, not dominant row text.

## Rejections

| rejected option | reason |
|---|---|
| Auto-inject sample into Generate/Paint | Violates sample learning policy. |
| Path-only detail | Does not explain type, dependencies, duplicate target, or learning use. |
| Placeholder Open action | No functional preview/focus route exists for this task. |
