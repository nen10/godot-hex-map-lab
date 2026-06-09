# ASSET-11 UX

## User Goal

Workspace tabs share the same project asset set. Selecting a catalog, object database, label database, layer stack, movement profile, validation suite, or generation profile in one workspace path makes that same project asset visible to the other paths that need it.

## Operation Steps

1. A workspace creates or receives a single session state.
2. The session owns one workspace asset context resource.
3. Generate and Paint receive the same context reference through the session.
4. Paint selection APIs publish project asset choices into the context.
5. Generate consumes the context catalog instead of resolving its own sample catalog when a project catalog is selected.

## Adopted UX

- The context represents project asset identity, not sample onboarding state.
- Missing project assets remain missing until later screens expose selection slots.
- Sample lookup behavior is not expanded in this task.

## Deferred UX

- Asset slot controls for every tab are deferred to `WORKSPACE-10` and screen tasks.
- Create-new actions are deferred to `ASSET-12`.
- Sample mode visibility controls are deferred to `SAMPLE-10`.
