# CAT-04 UX

## User Outcome

Existing v1 and v2 documents that do not carry catalog keys must still display with their numeric fallback tile values. The editor should expose compatibility warnings so authors know the document is using fallback data instead of silently appearing as fully catalog-backed.

## Workflow

1. Load or apply an existing document that has numeric tile fallback fields but no catalog assignment.
2. Terrain tiles display using those numeric fallback values.
3. Target readiness/debug state reports catalog compatibility warnings.
4. Documents with missing catalog keys or missing catalog resources do not silently draw unrelated tiles.

## Non-Goals

- Automatic catalog migration is deferred.
- Validation dashboard UI is deferred to `VAL-02`.
- Object scene placement compatibility is deferred to object placement tasks.
