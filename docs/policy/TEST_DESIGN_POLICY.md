# Test Design Policy

## Purpose

自動テストを、採用した UX / API の完了判断に使える Test path として設計する。

## Principles

- テストは UX / API の確認手段であり、設計根拠ではない。
- headless test の都合で悪い UI を残さない。
- 旧 UI widget、path text、numeric fallback、migration wording を保存するだけの test は更新または削除する。
- Core / Adapter tests は機能契約を守る。
- UI tests はユーザー目的に接続する state transition を見る。

## Test categories

| category | 責務 |
|---|---|
| Core / Adapter | データ構造、変換、query、validation の機能契約。 |
| Resource/API | canonical save/load/validation。 |
| UI headless | 画面の内部形状ではなく、ユーザー目的に接続する state。 |
| Debug scene | debug scene の状態切替と表示対象データ。 |
| Package | addon-only manifest、sample asset、clean project load。 |

## Parallel execution

- test output は `.godot_user/test-runs/<run-id>/` 以下へ置く。
- 固定 resource path や共有 log へ直接書き込まない。

## UI headless tests

良い確認:

- selected resource が state に反映される。
- validation issue が navigator model に渡る。
- workspace tab が担当 component を持つ。
- catalog key selection が document mutation に接続する。

避ける確認:

- private node 名の存在。
- LineEdit の placeholder。
- raw numeric fallback control の表示。
- 旧 UI layout の維持。

## Analog tests

CLEAN UI 再編中は新規作成しない。UI の印象が改善し、ユーザーが指示した場合だけ `ANALOG_TEST_POLICY.md` に従って作る。

## Docs

テストを追加・変更したら `docs/TEST.md` を更新する。
