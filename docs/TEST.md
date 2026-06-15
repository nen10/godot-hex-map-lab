# TEST.md

このファイルはテストの実行手順だけを扱う。

- テスト設計方針: [docs/policy/TEST_DESIGN_POLICY.md](policy/TEST_DESIGN_POLICY.md)
- テスト作成ログ: [docs/development_log/2026-06-14_TEST_CREATION_LOG.md](development_log/2026-06-14_TEST_CREATION_LOG.md)
- アナログテスト方針: [docs/policy/ANALOG_TEST_POLICY.md](policy/ANALOG_TEST_POLICY.md)

## 標準実行

```sh
./tools/test.sh
```

`./tools/test.sh` は addon package check と標準 Godot test scripts を実行する。

- 並列実行: `TEST_JOBS=4 ./tools/test.sh`（デフォルト）
- 直列実行: `TEST_JOBS=1 ./tools/test.sh`
- Godot 指定: `GODOT_BIN=/path/to/Godot ./tools/test.sh`
- macOS の証明書警告が出ても、終了コード `0` なら既知の非致命出力として扱う

## 標準対象

- `tools/package_addon.sh --check`
- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_generation_graph.gd`
- `tests/test_generation_graph_resource.gd`
- `tests/test_generation_graph_runner_dirty.gd`
- `tests/test_graph_runtime_build.gd`
- `tests/test_graph_load_context.gd`
- `tests/test_build_graph_canvas.gd`
- `tests/test_build_screen_full.gd`
- `tests/test_generation_promote.gd`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_workspace_layout_metrics.gd`
- `tests/test_workspace_layout_metric_evaluator.gd`
- `tests/test_workspace_layout_metric_gate.gd`
- `tests/test_editor_plugin.gd`
- `tests/test_editor_paint.gd`
- `tests/test_debug_scenes.gd`

## レポート

`./tools/test.sh` は必要に応じて次の実行レポートを作成する。

```text
.godot_user/test-runs/<run-id>/
.godot_user/ui-metrics/<run-id>/
```

Workspace UI metric gate は `tests/test_workspace_layout_metric_gate.gd` で実行される。

- P0 failures は標準受け入れゲートで、`0` でなければならない
- P1 issue count は現時点では report-only
- UI metric summary は `.godot_user/ui-metrics/<run-id>/workspace_layout_metrics.md` を参照

## 補助実行

静的 UI 監査:

```sh
python3 tools/ui_static_audit.py
```

`--strict` は明示的に failure exit を見たい場合だけ使う。

視覚確認:

```sh
./tools/debug_hex_orientation.sh
./tools/debug_generated_map.sh
```

詳細な操作説明は manual と対象 task の development log に置く。`docs/TEST.md` には追加しない。

## 手動 smoke

必要な場合のみ、Godot Editor 上で最小確認を行う。

1. `Hex Map Workspace` Dock を開き、対象 `HexTileMap` と Level Document を選択する。
2. Resources / Generate / Paint / Validate の主要タブが開くことを確認する。
3. project asset selection または未設定/validation state が見えることを確認する。
4. `Copy Debug Report` が Target Status など主要情報を取得することを確認する。
