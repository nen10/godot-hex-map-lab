# PROC-90 UX

## User Goal

Maintainers should have final committed addon package artifacts that match the current `addons/hex_map_kit/` tree, without turning packaging freshness into a noisy per-task test requirement.

## Operation Steps

1. Run `tools/package_addon.sh`.
2. Inspect the regenerated `dist/hex_map_kit-0.3.0.manifest.txt` and zip through git status/diff.
3. Run `./tools/test.sh` for normal package-check and headless Godot coverage.
4. Record whether `dist` changed in self-review.

## Adopted UX

- Packaging is a final process step and leaves inspectable committed artifacts.
- Standard tests continue to use temporary package-check artifacts.
- Release upload remains a manual human process.

## Deferred UX

- No new package UI is added.
- No recurring dist freshness gate is added to normal development tests.

## Existing UX Interference

- `./tools/test.sh` already verifies package contents with `--check`; this task should not make that check write committed `dist` files.
