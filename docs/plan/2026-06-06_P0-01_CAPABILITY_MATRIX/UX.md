# P0-01 Capability Matrix UX

作成日: 2026-06-07
Queue task: `P0-01`

## Goal

Phase 1 以降の schema / adapter / UI 実装が、現在の実装状態を誤認せずに着手できるように、Hex Map Kit の current capability と missing boundary を分類する。

## Operation Steps

1. Codex は current code と test path を読み、Generate / Edit / Runtime / Document / Test の capability を整理する。
2. Codex は plain `TileMapLayer` と `HexTileMapLayer` の役割差を、互換 path と primary path の観点で整理する。
3. Codex は object / label / overlay payload の保存 schema と表示 path を分類する。
4. Codex は後続 task が利用する risk register を作り、schema boundary / migration / validation / editor coupling のリスクを明示する。

## UX Classification

| Step | Evaluation | Target |
| --- | --- | --- |
| Generate/Edit/Runtime/Document/Test の分類 | 有用 + 追加 | 後続 task が実装済み範囲と未実装範囲を分けて判断できる。 |
| plain `TileMapLayer` と `HexTileMapLayer` の分類 | 有用 + 追加 | legacy compatibility と primary runtime helper を混同しない。 |
| object / label / overlay schema 分類 | 有用 + 追加 | `Array` payload を仕様根拠にせず、v2 schema task の migration 対象として扱う。 |
| 新 UI / schema 実装 | 不要 + 残置 | P0-01 は docs-only baseline。実装は後続 task で行う。 |

## Maintained UX

- Current Generate Dock / Edit Dock / `HexTileMapLayer` workflows are treated as existing capability, not changed by this task.
- Plain `TileMapLayer` apply remains compatibility behavior.
- `HexMapDocumentResource` version 1 payloads remain readable and are documented as migration inputs.

## Non-Goals

- No code or resource schema change.
- No migration implementation.
- No human approval gate before `P0-02`.
