# INFO-71 Tab Purpose Empty States UX

Date: 2026-06-08

## User goal

A game developer should understand what each Workspace tab is for and what one or two actions unblock the tab when the project is not configured yet.

## Flow

1. Open a Workspace tab in a new project.
2. Read a short purpose and empty-state line.
3. Follow one or two next actions that point to project asset setup or the tab's own command.
4. Use tooltip/help text for longer details.

## Visible contract

- Production tabs do not suggest bundled samples as the way to fill missing resources.
- Empty states expose `Next action` choices as one or two concise actions.
- Long policy detail such as sample behavior stays in tooltip/help text.
