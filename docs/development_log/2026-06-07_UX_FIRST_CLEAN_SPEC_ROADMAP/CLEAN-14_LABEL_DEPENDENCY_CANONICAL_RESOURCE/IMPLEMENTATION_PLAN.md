# CLEAN-14 Implementation Plan

## Steps

1. Add `HexLabelDefinitionResource`.
2. Replace `HexLabelDatabaseResource.labels` with `definitions: Array[Resource]` and lookup helpers.
3. Replace `HexMapDocumentDependencyResource.dependency_path` with `resource: Resource`.
4. Update document dependency validation for null resources and kind/type mismatch.
5. Update examples/tests/docs for resource references and debug resource paths.
6. Run `./tools/test.sh`, self-review, repair `repair-now` findings, update queue, and commit.

## Test Path

- `./tools/test.sh`
