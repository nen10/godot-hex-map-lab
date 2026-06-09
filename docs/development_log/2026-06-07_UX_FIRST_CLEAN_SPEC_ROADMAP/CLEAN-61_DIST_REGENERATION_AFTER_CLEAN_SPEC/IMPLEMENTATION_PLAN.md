# CLEAN-61 Implementation Plan

1. Mark CLEAN-61 `RUNNING` in the queue.
2. Run `./tools/package_addon.sh` to regenerate `dist/`.
3. Run `./tools/package_addon.sh --check` or equivalent temporary output and compare manifests.
4. Verify manifest excludes dev-only roots and legacy/migration docs.
5. Run `./tools/test.sh`, self-review, queue update, and commit generated dist artifacts.
