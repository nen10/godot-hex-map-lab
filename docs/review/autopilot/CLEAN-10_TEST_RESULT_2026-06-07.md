# CLEAN-10 Test Result

Task: `CLEAN-10_DOCUMENT_CANONICAL_SCHEMA`
Status: PASS
Date: 2026-06-07

## Commands

```sh
./tools/test.sh
```

## Result

PASS on Godot `v4.6.2.stable.official.71f334935`.

## Output summary

- Package manifest / zip check: PASS
- `tests/test_hex_core.gd`: PASS
- `tests/test_hex_map_generation.gd`: PASS
- `tests/test_hex_adapter.gd`: PASS
- `tests/test_hex_tile_map_layer.gd`: PASS
- `tests/test_editor_plugin.gd`: PASS
- `tests/test_debug_scenes.gd`: PASS

## Repaired during task

An intermediate full-suite run exited 0 but emitted script errors from stale test assertions reading removed document fields:

- `snapshot.map`
- `tool.document().map`
- `snapshot.tile_overrides`

These were classified as `repair-now` and rewritten to use canonical adapter accessors before the final passing run.

## Known environment output

- macOS Godot certificate warning: `get_system_ca_certificates` returns empty.
- Existing intentional warning paths in editor tests still emit warnings for invalid adjacency rules, missing source registry resources, empty placement masks, and empty source stack data.

## Repair status

`repair-now`: complete.
