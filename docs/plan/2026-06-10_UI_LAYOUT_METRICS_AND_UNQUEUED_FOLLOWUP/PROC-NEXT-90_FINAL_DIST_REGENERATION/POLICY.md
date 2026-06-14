# PROC-NEXT-90 Policy

## Adopted Decisions

- Regenerate `dist/` only as the final packaging process task for this roadmap.
- Commit regenerated manifest and zip when they differ from the current tree.
- Verify the committed package artifacts match the deterministic package-check artifacts from the passing standard test run.
- Keep `tools/test.sh` behavior unchanged.

## Rejected Decisions

- Do not add committed `dist` freshness to normal test gates.
- Do not publish, upload, sign, or otherwise release the package externally.
- Do not include repository docs, tests, debug scenes, tools, examples, `.godot_user/`, or existing `dist/` inside the addon zip.

## Resource / API / UI Boundary

- `tools/package_addon.sh` packages only `addons/hex_map_kit/`.
- Source docs and test files are repository material, not addon package contents.
- Bundled sample assets remain included as learning/onboarding assets, not as production workflow defaults.
- This task does not change editor UI, runtime behavior, or Resource/API contracts.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Temporary package-check output under `.godot_user/` | keep | Standard tests need non-committed package validation artifacts. | None; this is test output, not product fallback. | `./tools/test.sh` |
| Committed `dist` freshness outside normal tests | keep | Roadmap requires freshness only at final packaging boundary. | New roadmap explicitly changes packaging policy. | `tools/package_addon.sh`; compare against package-check output. |
| Sample assets in package | keep | Samples are shipped learning assets. | Package policy changes to exclude learning samples. | `tools/package_addon.sh --check`; `./tools/test.sh` |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| `dist/hex_map_kit-0.3.0.manifest.txt` | Lists only current `addons/hex_map_kit/` package paths. | Stale manifest misses newly added addon files. | `tools/package_addon.sh`; package-check comparison. |
| `dist/hex_map_kit-0.3.0.zip` | Zip contents match manifest and exclude dev-only paths. | Repository-only files leak into release package. | `tools/package_addon.sh`; `./tools/test.sh`. |
| `tools/test.sh` package-check output | Temporary output matches committed package artifacts. | Commit could contain artifacts from a different tree. | `cmp -s` against `.godot_user/package-check/<run>/`. |
