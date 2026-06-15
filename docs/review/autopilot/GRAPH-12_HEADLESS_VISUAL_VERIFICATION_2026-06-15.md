# GRAPH-12 Headless Visual Verification Report

Task: `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN`
Date: 2026-06-15

## Godot Documentation Basis

- Godot command line tutorial: `--headless` enables headless mode and is useful with `--script`; `--log-file` writes output/error logs to a specified path; `--path` selects the project path; `--script` runs a `.gd` command-line script.
  Source: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Godot `Viewport.get_texture()` returns the viewport texture and the docs recommend waiting for `RenderingServer.frame_post_draw` before saving a current texture, because early reads can be black or outdated.
  Source: https://docs.godotengine.org/en/stable/classes/class_viewport.html#class-viewport-method-get-texture
- Godot `Image.save_png(path)` saves an image as a PNG.
  Source: https://docs.godotengine.org/en/stable/classes/class_image.html#class-image-method-save-png

## Verification Method

Command:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph12-visual-verify.log --path . --script res://tools/graph12_visual_verify.gd
```

`tools/graph12_visual_verify.gd` executes the same editor path covered by GRAPH-12:

1. Instantiate `HexMapBuildScreen` with a `HexMapWorkspaceAssetContext` containing a `HexMapDocumentResource`.
2. Build and run `Shape -> Wall Field -> Connectivity -> Region Filter -> Item Generator`.
3. Confirm the selected `weighted_items` output has preview state.
4. Promote the selected output to an overlay layer in the Level Document.
5. Record a headless visual layout snapshot of the visible Build screen controls and their rectangles.
6. Attempt viewport PNG capture only when the display server is not `headless`. In this run it was skipped because Godot `--headless` uses the headless display driver here, so the stable completion gate is the Control layout/state record rather than a raster screenshot.

## Recorded Result

Artifact directory:

```text
/Users/nenten/Desktop/cosmos/projects/godot-hex-map-lab/.godot_user/visual-verification/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/2026-06-15_154938
```

Files:

- `.godot_user/visual-verification/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/2026-06-15_154938/graph12_visual_verification.md`
- `.godot_user/visual-verification/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/2026-06-15_154938/graph12_visual_verification.json`
- `.godot_user/test-runs/graph12-visual-verify.log`

Result summary:

| item | value |
|---|---:|
| run_ok | true |
| preview_available | true |
| promote_available | true |
| promote_ok | true |
| graph nodes | 5 |
| graph connections | 4 |
| selected node | `weighted_items` |
| visible controls | 39 |
| graph canvas visible | true |
| node palette visible | true |
| output preview visible | true |
| inspector visible | true |
| Generate action visible | true |
| document overlay layers | 1 |
| generated overlay cells | 10 |
| raster capture | skipped under `--headless` |

Headless visual content confirmed:

- Build screen visual work surface exists as the primary canvas surface.
- Graph canvas, node palette, output preview, inspector, and Generate action are visible in the Control tree with nonzero rectangles.
- The selected item-generator output has preview state before Promote.
- Promote writes generated overlay data to the active Level Document.

The macOS certificate warning in the log is non-fatal and matches the standard test output pattern for this environment.
