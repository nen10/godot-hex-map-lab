# PKG-71 Policy

## Requirement

The clean package/project check must verify production startup without samples:

- plugin config/script is loadable
- sample mode OFF is the clean project default
- missing assets become routed validation issues
- project document/catalog/object resources can be created
- user TileSet and user PackedScene are accepted
- `./tools/test.sh` package check passes

## Boundary

Bundled sample learning availability is covered by `PKG-70`.
