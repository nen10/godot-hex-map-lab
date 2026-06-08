# Package Manual

This repository is the development project. Public addon artifacts are generated from `addons/hex_map_kit/` only.

## Build Addon Package

Run:

```sh
./tools/package_addon.sh
```

Output:

```text
dist/hex_map_kit-<version>.zip
dist/hex_map_kit-<version>.manifest.txt
```

The version comes from:

```text
addons/hex_map_kit/plugin.cfg
```

## Check Package Manifest

Run:

```sh
./tools/package_addon.sh --check
```

`--check` writes temporary artifacts under `.godot_user/package-check/` and validates:

- required addon files are present,
- bundled learning sample atlas, catalog, and scene are present,
- development-only roots are absent.

The standard test script runs this check before Godot headless tests:

```sh
./tools/test.sh
```

## Included In The Addon Zip

The package includes:

```text
addons/hex_map_kit/
  LICENSE
  plugin.cfg
  plugin.gd
  core/
  adapter/
  editor/
  assets/
    sample_hex_tiles.png
    sample_hex_tile_catalog.tres
    sample_spawn_marker.tscn
```

## Excluded From The Addon Zip

The package excludes:

```text
docs/
tests/
debug/
tools/
examples/
.godot/
.godot_user/
dist/
```

Docs and examples are source-repository material. The addon zip is intentionally small and installable into another Godot project under `res://addons/hex_map_kit/`.

## Production Assets And Samples

The zip includes bundled samples so new users can learn the editor after installation. They are not the production default workflow. In a project, create or select project-owned documents, catalogs, TileSets, object databases, label databases, generation profiles, validation suites, export profiles, and Runtime Handoff destinations through Hex Map Workspace.

When a sample is useful as a starting point, duplicate it from Settings / Samples into a project path, then edit the project copy. The duplication flow copies the sample catalog, tile texture, object scene, and catalog scene-entry references into project-owned files. Package checks verify that bundled sample files are present; feature completion tests verify that normal editor screens work with project assets and sample mode OFF.

## Clean Project Check

The standard `./tools/test.sh` flow covers a clean project contract:

- plugin configuration and script load,
- missing project assets report routed validation issues before selection,
- new project Level Document and Tile Catalog creation,
- arbitrary user TileSet assignment and catalog entry creation,
- Object Database creation from a user `PackedScene`,
- sample mode OFF throughout the production setup.

## Release Check

Do not upload a generated zip automatically. Before public upload, perform a human release check:

1. Run `./tools/test.sh`.
2. Run `./tools/package_addon.sh`.
3. Inspect `dist/hex_map_kit-<version>.manifest.txt`.
4. Install the zip contents into a clean Godot project.
5. Enable the plugin and open at least one runtime/editor workflow example from the source repository.
