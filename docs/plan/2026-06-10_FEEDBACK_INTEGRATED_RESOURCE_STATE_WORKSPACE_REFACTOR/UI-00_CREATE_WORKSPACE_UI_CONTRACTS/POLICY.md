# UI-00 Policy

## Adopted Decisions

- Workspace screens render from ViewState/root state boundaries, not private flag recombination.
- Every tab separates normal visible text from tooltip/detail/debug-report content.
- Debug, filepath, node path, raw JSON, numeric fallback, internal ids, and raw state names are not normal UI.
- Resource rows are compact/adaptive controls with status conveyed by icon/short state plus tooltip detail.
- Visible buttons must change state, open a real picker/dialog, run a real operation, or be removed.
- Generate receives a caution policy: preserve functional parameter/progress/preview/apply controls until UI-03 repairs presentation using Generation ViewState.

## Rejected Decisions

- Do not implement UI-01/UI-02/UI-03 visual changes in UI-00.
- Do not keep Details buttons as placeholders for debug text.
- Do not make sample assets silent defaults or completion proof.
- Do not add analog tests.
- Do not protect old widget-shape tests when they contradict the visible contract.

## Resource / API / UI Boundary

- Resource/API: Resource ownership and dependency hydration remain governed by Resource/state tasks.
- State: root state and screen ViewStates are the source for rendering decisions.
- UI: UI-00 defines visible contract documents; later tasks implement against them.
- Debug: debug report surfaces can include internal state; normal tabs cannot rely on raw debug labels.

## Unresolved But Allowed Later

- Exact icon glyphs and responsive breakpoints are chosen in UI-01.
- Exact Settings toggle layout is chosen in UI-02.
- Exact Generate empty-area repair is chosen in UI-03.
