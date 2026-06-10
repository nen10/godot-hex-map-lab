# UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Preserve the current Catalog screen while moving ownership behind it | medium | low | medium | adopt | Users should see the same entry list/detail/create/validate flow with clearer internal ownership. |
| Redesign Catalog previews now | high later | medium | high | reject | `CAT-NEXT-11` owns rich preview UI. |
| Move all catalog controls out of Paint immediately | medium | high | medium | reject | Paint still needs catalog-key selection for brush payloads. |
| Add invisible component ownership proof | medium | low | low | adopt | Tests can verify Catalog ownership without adding debug UI. |

## User Goal

Catalog editing should feel like a Catalog screen responsibility: entries are listed, inspected, created, and validated from the Catalog workflow, while Paint only consumes chosen catalog keys for brush payloads.

## Adopted Experience

- The Catalog tab continues to show the same project catalog slot, entry list/detail state, creation availability, and validation status.
- Entry previews remain textual state proof until the queued rich preview UI task.
- Paint continues to expose brush selection by catalog key, but it does not claim normal catalog entry management.
- No new visible sample fallback, debug text, path dump, raw JSON, or coordinate-primary workflow is introduced.

## Experience Steps

1. Open the Workspace and select Catalog.
2. Create or select a project Tile Catalog.
3. Assign an arbitrary project TileSet or PackedScene.
4. Create atlas or scene entries.
5. Inspect list/detail/preview/status fields and run validation from the Catalog workflow.
6. Switch to Paint and consume catalog keys for brush defaults without exposing Catalog management as Paint-owned work.
