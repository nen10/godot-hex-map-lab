# ASSET-01 UX

## User Goal

Developers and roadmap tasks can see which current editor UI slots already support project assets, which are sample-only, which still expose raw/path/debug controls, and which cleanup task owns each gap.

## Operation Steps

1. Review current editor workspace and dock UI source.
2. Identify every user-visible asset or asset-like slot.
3. Classify each slot as main flow, sample flow, debug flow, or mixed flow.
4. Record whether arbitrary project asset selection exists today.
5. Record missing/invalid validation behavior and cleanup task ownership.

## Adopted UX

- Inventory treats user-selected project assets as the production path.
- Samples are classified as learning/sample flow unless already isolated from production.
- Raw text, raw numeric tile fields, fixed sample paths, and hidden fallback are classified as cleanup targets.

## Deferred UX

- This task does not redesign controls or add the unified AssetSlot component.
- This task does not add analog tests.

## Existing UX Interference

Current workspace tab names exist, but most concrete controls still live in the edit/generate dock implementation. The inventory records current placement and the intended owning screen when the roadmap already assigns one.
