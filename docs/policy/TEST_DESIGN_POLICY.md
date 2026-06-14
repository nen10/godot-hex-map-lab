# Test Design Policy

## Purpose

自動テストを、採用した UX / API の完了判断に使える Test path として設計する。

## Principles

- テストは UX / API の確認手段であり、設計根拠ではない。
- headless test の都合で悪い UI を残さない。
- UI first impression を要する task は、headless API availability だけを completion proof にしない。
- 旧 UI widget、path text、numeric fallback、migration wording を保存するだけの test は更新または削除する。
- No sample-only completion: sample preset success だけで feature complete と判定しない。sample だけで動く UI は `sample-only prototype` として扱う。
- production feature screen の test は、sample mode OFF の project asset selection state、user-selected Resource、または未設定/validation state を確認する。sample mode ON/OFF の挙動は別テストで扱う。
- Core / Adapter tests は機能契約を守る。
- UI tests はユーザー目的に接続する state transition を見る。

## Test categories

| category | 責務 |
|---|---|
| Core / Adapter | データ構造、変換、query、validation の機能契約。 |
| Resource/API | canonical save/load/validation。 |
| UI headless | 画面の内部形状ではなく、ユーザー目的に接続する state。 |
| Debug scene | debug scene の状態切替と表示対象データ。 |
| Package | addon-only manifest、sample asset、clean project load。Committed `dist` freshness は final process step で確認し、通常 task の test gate にはしない。 |

## Parallel execution

- test output は `.godot_user/test-runs/<run-id>/` 以下へ置く。
- 固定 resource path や共有 log へ直接書き込まない。

## UI headless tests

良い確認:

- selected resource が state に反映される。
- sample mode OFF で project asset selection が主導線になる。
- missing project asset が visible state / validation issue になる。
- validation issue が navigator model に渡る。
- workspace tab が担当 component を持つ。
- catalog key selection が document mutation に接続する。

避ける確認:

- private node 名の存在。
- sample preset button の成功だけで feature screen complete とみなすこと。
- bundled sample path が通常 selector に silent default として入ること。
- LineEdit の placeholder。
- raw numeric fallback control の表示。
- 旧 UI layout の維持。

## Analog tests

CLEAN UI 再編中は新規作成しない。UI の印象が改善し、ユーザーが指示した場合だけ `ANALOG_TEST_POLICY.md` に従って作る。

## Docs

テストを追加・変更したら、coverage / 作成ログは `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` に記録する。設計方針が変わる場合は本ファイルを更新する。`docs/TEST.md` は実行コマンド、標準対象、レポート出力、補助実行手順が変わる場合だけ更新する。

### CLEAN UI再編中のアナログテスト扱い

- 新規アナログテスト文書は CLEAN UI再編中は作成しない。
- 既存 `tests/analog_test/` 文書は history / reference であり、clean UX acceptance ではない。
- NEXT-03-style analog test pack は現在の roadmap queue には scheduled されていない。
- manual-only task は `./tools/test.sh` と self-review で完了確認する。
- UI改善後にユーザーが明示した場合だけ、アナログテスト作成を再開する。

### UI asset selection completion

- No sample-only completion: sample preset success だけで editor-facing feature を complete と判定しない。
- sample だけで成立する UI は `sample-only prototype` として扱い、sample/package integrity task 以外の production acceptance には使わない。
- feature screen の headless test は sample mode OFF の project asset selection state、user-selected Resource、または未設定/validation issue を確認する。
- sample mode ON/OFF と bundled sample asset の妥当性は、main feature completion とは別の sample/package contract として検証する。

### UI static audit

`UI-METRIC-02` adds a report-only static audit for Workspace UI contract risks:

```sh
python3 tools/ui_static_audit.py
```

The audit reports suspicious button wiring, placeholder button text, debug/raw/path visible text patterns, generic `EditorResourcePicker` usage, and tab scroll-container suspicion. It exits 0 by default because P0/P1 gating is scheduled later. Use `--strict` only when a caller intentionally wants findings to return a nonzero exit code.

### UI metric reports

`UI-METRIC-07` adds the standard runtime Workspace metric gate to `./tools/test.sh`. The gate writes JSON and Markdown reports under:

```text
.godot_user/ui-metrics/<run-id>/
```

`./tools/test.sh` runs `tests/test_workspace_layout_metric_gate.gd` for this gate:

- P0 is a hard acceptance gate: `P0 failures` must be `0`.
- P1 counts are report-only for now.
- Metric reports are written to `.godot_user/ui-metrics/<run-id>/workspace_layout_metrics.json` and `.md`.

`./tools/test.sh` executes test scripts in parallel by default with `TEST_JOBS=4`.
Set `TEST_JOBS=1` to force serial execution.

## テスト運用ルール

テスト設計・coverage・作成ログの責務は `docs/TEST.md` から分離し、本ファイルと `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` に集約する。

- テスト作成時は、コマンド実行のみで完了する追加/更新は `tools/test.sh` を合わせて更新する。
- CLEAN UI 再編中はアナログテスト新規作成しない。既存文書は履歴参照扱い。
- No sample-only completion。production feature の完了は sample preset だけでは判断しない。
- Clean completion が必要な UI テストは `sample mode OFF` の project asset 選択状態、または未設定/validation 状態を確認する。
- `tools/package_addon.sh --check` / package manifest / `.godot_user` / `dist` の取り扱いは検証ルートの固定前提とする。
- `tools/ui_static_audit.py` と `UI-METRIC-*` 系は「静的監査・metric gate」の一部として扱い、`--strict` は明示指定時のみ非0終了を許可する。

## テスト作成ログ（要約）

詳細ログは [docs/development_log/2026-06-14_TEST_CREATION_LOG.md](../development_log/2026-06-14_TEST_CREATION_LOG.md) に集約する。  
本 policy では方針と受け入れ基準を維持し、網羅ログ自体は `docs/development_log` へ集約する。`docs/TEST.md` は実行参照として維持する。
