# PKG-70 UX

## User Goal

Bundled sample assets should be available for learning after installation, but they must remain opt-in and separate from production project asset selection.

## Contract

- The addon package includes the sample catalog, tile texture, and object scene.
- Sample mode OFF does not inject bundled samples into main Generate/Paint selectors.
- Sample mode ON exposes bundled samples as learning candidates.
- Selected project assets remain primary when sample mode is ON.

## Non-goals

- Do not make sample mode the default.
- Do not add analog tests.
- Do not change production asset workflows.
