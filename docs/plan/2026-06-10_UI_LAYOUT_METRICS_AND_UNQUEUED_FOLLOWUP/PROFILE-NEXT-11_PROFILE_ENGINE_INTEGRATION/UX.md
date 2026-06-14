# PROFILE-NEXT-11 UX

## User Goal

When a project selects concrete Validation Suite, Generation Profile, or Export Profile Resources, the normal engine paths should honor those profiles. If no profile is selected, the current default behavior should remain unchanged and visibly optional.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Use selected profile Resources as execution options | high | medium | medium | adopt | Makes profile Resources real behavior controls rather than display-only schemas. |
| Keep profiles as screen-only summaries | low | high | low | reject | Would leave PROFILE-NEXT-10 at surface depth and fail this follow-up. |
| Auto-inject sample/preset profiles when missing | low | high | low | reject | Violates optional missing state and sample separation policy. |
| Build new profile editor UI | medium | medium | high | reject | Not required to prove execution integration. |

## Experience Steps

1. User selects or creates profile Resources through existing Workspace asset slots.
2. Validate uses the selected Validation Rule Suite to skip disabled rules and apply severity overrides.
3. Generate uses the selected Generation Profile seed, shape, and terrain/connectivity options when building generation snapshots.
4. Export reports and applies selected Export Profile output type/file extension/inclusion flags in the runtime handoff result path.
5. Missing profiles remain optional and preserve current default execution behavior.

## Adopted UX

- Profiles become normal workflow inputs when explicitly selected.
- Missing profiles stay visible as optional missing state.
- Existing screen summaries continue to describe selected schemas.

## Rejected UX

- No sample profile is silently selected.
- No raw JSON profile editor is introduced.
- No unsupported export button is surfaced.
