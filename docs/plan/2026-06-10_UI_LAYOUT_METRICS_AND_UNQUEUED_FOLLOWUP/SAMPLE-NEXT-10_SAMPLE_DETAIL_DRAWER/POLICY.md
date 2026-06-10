# SAMPLE-NEXT-10 Policy

## Scope

SAMPLE-NEXT-10 adds sample inspection state to Settings. It may add selected sample metadata and mounted detail text. It must not change production source selection or fallback behavior.

## Requirements

- Detail drawer exposes sample asset type, dependencies, duplicate target, and learning use.
- The detail drawer is visible/mounted through the Settings sample panel.
- Sample catalog duplicate remains the only project-copy action.
- Generate/Paint continue to ignore bundled samples as automatic production fallback.

## Fallback / Defer Ledger

| item | disposition | rationale |
|---|---|---|
| Per-row preview thumbnails | defer | Catalog/preview components own rich previews. |
| Open sample action | reject | Removed until a real focus/preview route exists. |
| Production fallback from sample | reject | Policy forbids silent sample production source. |

## Test Policy

- Extend existing sample settings duplicate test.
- Assert detail drawer fields before and after duplicate.
- Run `./tools/test.sh`.
