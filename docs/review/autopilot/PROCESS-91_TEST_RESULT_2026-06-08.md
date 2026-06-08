# PROCESS-91 Test Result

Date: 2026-06-08

## Commands

- `./tools/package_addon.sh`
- `./tools/package_addon.sh --check --output-dir /tmp/hex-map-process-91-package-check`
- `diff -u dist/hex_map_kit-0.3.0.manifest.txt /tmp/hex-map-process-91-package-check/hex_map_kit-0.3.0.manifest.txt`
- `wc -l dist/hex_map_kit-0.3.0.manifest.txt /tmp/hex-map-process-91-package-check/hex_map_kit-0.3.0.manifest.txt`
- `cmp -s dist/hex_map_kit-0.3.0.zip /tmp/hex-map-process-91-package-check/hex_map_kit-0.3.0.zip`
- `shasum -a 256 dist/hex_map_kit-0.3.0.zip dist/hex_map_kit-0.3.0.manifest.txt`
- `./tools/test.sh`

## Result

- PASS: committed `dist` artifacts were regenerated.
- PASS: committed manifest and fresh temporary manifest match exactly.
- PASS: committed zip and fresh temporary zip are byte-identical.
- PASS: standard project suite.

## Package proof

- Manifest entries: 144.
- Zip SHA-256: `9f6159417abb3174e86ec60855c08e430a0568a63c31bc8db4984f527b4872be`.
- Manifest SHA-256: `bcb82174b40e565c8281b923032c791354c313d036116955cf4e4e8b6698278b`.

## Notes

- `tools/test.sh` continues to run only the temporary package manifest check; committed dist freshness was handled by this final process task.
- Godot emitted the existing macOS CA certificate message and expected warning-path validation messages.
