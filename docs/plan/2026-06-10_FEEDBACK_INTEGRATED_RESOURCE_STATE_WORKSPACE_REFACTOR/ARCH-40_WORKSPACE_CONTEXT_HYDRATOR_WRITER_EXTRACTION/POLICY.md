# ARCH-40 Policy

## Adopted Decisions

- `HexMapWorkspaceBindingService` is the hydrator/writeback service for this slice.
- Workspace may keep session/edit-tool refresh side effects, but should not assemble node/document/dependency relationship state itself.
- Service results must identify their source so tests can assert the boundary.
- Shared dependency writeback should cover all shared dependency slots through service-owned slot enumeration.

## Rejected Decisions

- Do not create UI-only state just to satisfy tests.
- Do not preserve Workspace-owned relationship assembly when a service can own it.
- Do not broaden into `ARCH-41` screen script extraction.

## Resource / API / UI Boundary

- Resource: Document dependencies remain canonical for shared resources.
- API: Binding service exposes hydration snapshots, writeback snapshots, slot writeback, and shared dependency sync.
- UI: Workspace renders service results and performs only necessary UI/session synchronization.

## Compatibility

The addon is unpublished, so snapshot fields may gain service-source metadata directly.
