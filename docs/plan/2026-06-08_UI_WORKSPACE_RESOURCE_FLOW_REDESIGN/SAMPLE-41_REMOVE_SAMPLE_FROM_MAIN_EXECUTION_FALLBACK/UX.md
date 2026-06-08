# SAMPLE-41 UX

## User Goal

Turning on sample learning visibility should not make Generate or Paint silently use bundled sample assets as production inputs.

## Operation Steps

1. Open Settings / Samples.
2. Enable sample learning visibility.
3. Observe learning candidates in appropriate workspace screens.
4. Leave Catalog unselected and check Generate/Paint readiness.
5. Duplicate the sample catalog to a project path when production use is desired.

## Adopted UX

- Sample mode reveals learning candidates, not execution fallback.
- Generate/Paint remain unconfigured until a project Catalog is selected or created.
- A direct bundled sample selection is marked as `SOURCE_SAMPLE` with a warning.
- Duplicated project copies are treated as normal `SOURCE_PROJECT` production assets.

## Rejected UX

- No bundled sample catalog as automatic Generate/Paint fallback.
- No treating `res://addons/hex_map_kit/assets/` selections as project assets.
- No sample success as proof of production feature completion.

## Existing UX Interference

- Standalone no-session debug helpers may still load sample assets for internal tests; workspace/session-driven editor UX must not.
