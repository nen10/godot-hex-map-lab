# PROC-90 POLICY

## Adopted Decisions

- `dist/` freshness is handled by this final process task.
- `tools/package_addon.sh` remains the source of truth for package manifest and zip construction.
- Public upload/signing is outside this task.

## Rejected Decisions

- Do not add committed `dist` freshness to normal `./tools/test.sh` gates.
- Do not modify addon version unless a separate release task requires it.

## Resource / API / UI Boundary

Packaging does not change Resource/API/UI behavior. It only refreshes distributable artifacts from the current addon tree.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| package script fallback | reject | existing package script is the source of truth | none | `tools/package_addon.sh` |
| public upload mirror | out of scope | requires external release action | separate release task | none |

## Completion Criteria

- `dist/hex_map_kit-0.3.0.manifest.txt` matches the generated addon manifest.
- `dist/hex_map_kit-0.3.0.zip` validates through `tools/package_addon.sh`.
- `./tools/test.sh` passes.
