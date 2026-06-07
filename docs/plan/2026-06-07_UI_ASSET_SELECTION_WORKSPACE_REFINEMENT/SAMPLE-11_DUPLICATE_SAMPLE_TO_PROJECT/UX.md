# SAMPLE-11 UX

## User Goal

A user can start from bundled samples for learning, then create project-owned copies so production work is no longer tied to addon sample assets.

## Operation Steps

1. In Settings / Samples, the user chooses `Duplicate To Project` for the bundled sample catalog.
2. The user chooses a project `.tres` destination for the catalog.
3. The sample tile texture and sample object scene are copied beside the project catalog.
4. The duplicated catalog references those project copies and enters the workspace asset context.

## Adopted UX

- Duplicate is explicit; samples are not assigned to project context without the action.
- The duplicated catalog is a project asset source, not a sample fallback.
- Dependency copies stay near the duplicated catalog path.

## Deferred UX

- Rich conflict handling and custom dependency filenames are deferred.
- First-run CTA remains `SAMPLE-12`.
