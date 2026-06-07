# P0-02 Schema Boundary Decisions UX

作成日: 2026-06-07
Queue task: `P0-02`

## Goal

後続の Level Document v2 / Catalog / Layer Stack / Object / Validation task が、既存 v1 payload をどう扱うかで迷わないように、maintain / migrate / remove の判断を固定する。

## Operation Steps

1. Codex は `P0-01` の capability matrix と risk register を読む。
2. Codex は object / label / overlay / tile override / TileSet / scene / custom data の boundary を分類する。
3. Codex は saved `.tres` compatibility を維持しながら、primary UX を typed v2 schema と catalog key へ移す判断を記録する。
4. Codex はこの判断を `SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md` として保存する。

## UX Classification

| Step | Evaluation | Target |
| --- | --- | --- |
| v1 payload maintain / migrate / remove 判断 | 有用 + 追加 | v2 実装で互換性を壊さず、ただし v1 Array を仕様の中心にしない。 |
| TileSet / scene / custom data boundary 判断 | 有用 + 追加 | document、catalog、object database、validation の責務を分ける。 |
| Human approval gate | 不要 + 廃止 | validated roadmap に従い、Codex が合理的な判断を固定する。 |

## Maintained UX

- Existing v1 documents remain loadable.
- Existing Generate/Edit/Runtime workflows are not changed by P0-02.
- Numeric tile controls remain compatibility/advanced behavior until catalog UI replaces normal authoring controls.

## Non-Goals

- No schema implementation.
- No migration helper implementation.
- No resource class creation.
- No test file addition.
