# PKG-03 Test Result

Task: `PKG-03`  
Date: 2026-06-07  
Status: PASS

## Commands

```sh
./tools/package_addon.sh --check
./tools/package_addon.sh
./tools/test.sh
```

## Result

- Package manifest check: PASS.
- Normal package build: PASS.
- Full test suite: PASS on Godot `v4.6.2.stable.official.71f334935`.

## Package Proof

- Generated check artifact: `.godot_user/package-check/.../hex_map_kit-0.3.0.zip`.
- Generated release artifact path: `dist/hex_map_kit-0.3.0.zip`.
- Generated release manifest path: `dist/hex_map_kit-0.3.0.manifest.txt`.
- Manifest entry count: 103.
- Dev-only roots absent from manifest: `docs/`, `tests/`, `debug/`, `tools/`, `examples/`, `.godot_user/`, `dist/`.

## Notes

- `dist/` is ignored because package artifacts are generated release outputs, not source files.
- Public upload was not performed; it remains a human release check.
- The macOS certificate `ret != noErr` message remains a known non-fatal Godot output noted in `docs/TEST.md`.

