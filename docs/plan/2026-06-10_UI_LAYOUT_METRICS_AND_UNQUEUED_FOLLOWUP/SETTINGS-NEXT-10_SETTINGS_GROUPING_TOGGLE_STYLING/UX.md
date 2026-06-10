# SETTINGS-NEXT-10 UX

## User Job

A developer opens Settings to understand editor preferences, sample learning controls, and debug opt-ins without confusing them with production asset setup.

## Required Visible State

| group | UX requirement |
|---|---|
| Sample Learning | Sample visibility/copy controls and sample learning rows are grouped together. |
| Debug | Debug numeric fallback is isolated and clearly opt-in. |
| Project Defaults | Settings points back to Resources for production defaults instead of hosting asset selectors. |
| UI Preferences | Editor preference space is separated from samples/debug. |

## Toggle / Checkbox Rules

- Boolean controls use CheckBox/toggle widgets.
- Tooltip text carries detail about consequences and boundaries.
- Visible boolean prose like `true`/`false` remains absent.

## Rejections

| rejected option | reason |
|---|---|
| Mixed flat Settings list | Makes sample/debug/default ownership ambiguous. |
| Sample paths as visible row text | Path detail belongs in tooltip/detail. |
| Production defaults in Settings | Resources remains the production asset owner. |
