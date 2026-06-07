# CLEAN-30 UX

作成日: 2026-06-07
Roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`
Queue: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md`

## 目的

Editor UI を file size ではなく、ゲーム開発者の作業目的で分類する。後続の CLEAN-20 / CLEAN-21 / CLEAN-22 / CLEAN-24 / CLEAN-25 / CLEAN-26 / CLEAN-33 が、どの UI を維持・移動・統合・advanced 化・削除するか判断できる状態にする。

## Operation Steps

1. 現在の Generate Dock / Edit Dock / helper component を source から読む。
2. UI 要素を user task に分解する。
3. 各 UI 要素を `keep-in-place` / `move-to-screen` / `merge-with-existing` / `advanced-only` / `delete` に分類する。
4. path text、fallback UI、legacy / migration wording の削除候補を明示する。
5. 後続 task の screen/component へ接続する。

## UX 評価

| 操作 | 評価 | 目標 |
|---|---|---|
| Generate の seed / shape / generator controls | 有用 / 維持 | Generate screen の中心に残す |
| Document path を LineEdit で編集する | 不要 / 廃止 | Document Header の ResourcePicker / FileDialog / read-only saved status へ置換 |
| Catalog key を brush で選ぶ | 有用 / 維持 | Paint / Generate の通常入力として維持 |
| Catalog resource / entries を編集できない | 不要 / 廃止 | Catalog screen を追加する |
| raw `source_id / atlas_coords` を通常画面で触る | 不要 / 廃止 | Catalog entry editor の詳細または debug に隔離 |
| Object id / raw properties text を通常操作にする | 不要 / 廃止 | Object Palette と type-aware property editor へ置換 |
| Validation issue を一覧し focus する | 有用 / 維持 | Validate screen へ移して修正行動に接続 |
| QA batch / score / promotion が API だけにある | 不要 / 廃止 | Seed Lab / QA screen として visible workflow にする |
| Layer Stack を backend だけで使う | 不要 / 廃止 | Layer Stack screen に role / visible / z-index / writable target を置く |

## 不変条件

- Inventory は UI 実装そのものを変更しない。
- 「大きいから分ける」という理由を使わない。
- 後続 task はこの inventory を root にして screen / component / deletion plan を作る。

## 出力

- `docs/review/roadmap/EDITOR_UX_COMPONENT_INVENTORY_2026-06-07.md`
