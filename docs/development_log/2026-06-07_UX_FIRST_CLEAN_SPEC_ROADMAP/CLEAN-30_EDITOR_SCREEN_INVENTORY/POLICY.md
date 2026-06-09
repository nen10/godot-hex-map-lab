# CLEAN-30 Policy

作成日: 2026-06-07

## 採用方針

1. UI 分類はユーザーの作業目的で判断する。
2. file size、class size、headless test の触りやすさを分類根拠にしない。
3. `delete` は、path text、legacy / migration wording、fallback UI、通常導線の raw internal value に使う。
4. `advanced-only` は、通常ユーザーの目標には不要だが debug / generator tuning / support に残す価値があるものに使う。
5. `move-to-screen` は、現在の画面にあるが別の作業目的へ属する UI に使う。
6. `merge-with-existing` は、同じ作業目的が複数箇所に分散している UI に使う。
7. `keep-in-place` は、現在の画面の主要目的と一致し、後続 redesign でも同 screen に残す UI に使う。

## Screen ownership

| User task | Screen / component owner |
|---|---|
| New / Open / Save / Save As / Dirty / Validate summary | Document Header |
| Seed / shape / generator pipeline | Generate |
| Cell edit / brush / target viewport operation | Paint / Edit |
| TileSet / catalog resource / entry list / preview / tags | Catalog |
| Object database / object definitions / type-aware properties | Object Palette |
| Role layers / visible / locked / z-index / apply target | Layer Stack |
| Issue list / severity / focus / fix suggestion | Validate |
| Batch seeds / score table / selected preview / promote | Seed Lab / QA |
| Runtime sample / package export / debug report | Runtime / Export |

## Evidence policy

Inventory rows must cite current source files or tests where possible. Documentation-only claims are insufficient unless the inventory is explicitly about missing screen coverage.

## Test policy

- This task adds no automated test and does not update `docs/TEST.md`.
- Completion proof is `./tools/test.sh`.
- Later implementation tasks update tests when they delete or replace old UI contracts.
