# PKG-71 UX

## User Goal

A clean project should be able to start from project-owned assets without bundled samples being silently injected.

## Contract

- Plugin configuration loads.
- Empty workspace reports missing project assets before selection.
- User can create a Level Document and Tile Catalog.
- User can assign an arbitrary TileSet.
- User can create an Object Database and object definition from a project PackedScene.
- Package check passes.

## Non-goals

- Do not add analog tests.
- Do not require sample mode for clean project setup.
- Do not make package artifacts part of source control.
