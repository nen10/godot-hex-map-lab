# テスト作成ログ（2026-06-14）

本ログは `docs/TEST.md` から分離したテスト作成ログを集約する。`docs/TEST.md` はテスト実行手順のみを扱う。

## 1) 方針

- テストは UX / API の completion proof を担うものとして設計する。  
- headless テストの都合で不自然な UI の退行を許容しない。  
- `sample` 成功のみで完成としない（No sample-only completion）。  
- sample mode が ON/OFF のテストは分離し、production feature の完了は `sample mode OFF` の project resource 依存状態で判断する。  
- path text / numeric fallback / 過去互換 UI のみを残すテストは見直し対象とする。  
- CLEAN UI 再編中は新規アナログテストを追加せず、必要時のみ `ANALOG_TEST_POLICY.md` に従って作成する。  
- `./tools/test.sh` はテスト追加・変更時に同時更新し、標準出力先に固定パス依存を書き込まない。  
- `tools/ui_static_audit.py` と `UI-METRIC-0X` は静的監査/metric gateとして扱い、`--strict` は明示実行時のみ非0終了とする。  

## 2) テスト実行ログ方針

- `docs/TEST.md` は実行手順、標準対象、レポート出力、補助コマンドのみを保持し、実行結果評価と変更ログは本ログまたは各ドキュメントへ委譲する。  
- `docs/policy/TEST_DESIGN_POLICY.md` には実行方針と責務を残す。  
- 追加 log（`QA-xx` / `UI-xx` / `STATE-*` / `ARCH-*` / `ASSET-*` / `PERF-*` / `PROFILE-*` / `SAMPLE-*`）は、
  - 実装対象のログディレクトリ（`docs/development_log/YYYY-MM-DD_*`）
  - もしくは roadmap 文書
  に分散管理し、`docs/TEST.md` へは列挙しない。  

## 3) テスト責務ログ（簡易版）

- `tests/test_hex_core.gd`
  - Hex 基本構造、タイル座標、近傍・経路・到達性、対称系タグ生成の検証
- `tests/test_hex_map_generation.gd`
  - 形状/overlay/アイテム生成、連結性回復、interrupt/cancel、seed 決定、対称性
- `tests/test_generation_graph.gd`
  - Generation Graph の Dictionary model、port 型検証、headless node pass 連鎖、Source ノード、topo 実行
- `tests/test_generation_graph_resource.gd`
  - Generation Graph Resource の Dictionary 相互変換、save/load round-trip、runner 互換、embed snapshot 永続化
- `tests/test_generation_graph_runner_dirty.gd`
  - Generation Graph runner の dirty cache 再利用、downstream 再計算、interrupt/cancel、partial cache 非確定
- `tests/test_graph_runtime_build.gd`
  - Generation Graph Resource の runtime build API、seed 再現性、embed/reference semantics、editor 非依存、HexTileMapLayer 適用
- `tests/test_graph_load_context.gd`
  - Generation Graph Resource の editor load context ownership、新規 node embed 復元、overwrite generated 層置換、手動層保持
- `tests/test_build_graph_canvas.gd`
  - Build tab graph canvas、typed connection rejection、GraphEdit→Dictionary model同期、3-node chain preview、run cache/dirty/failure state、failure node highlight、palette/inspector contract
- `tests/test_build_screen_full.gd`
  - Build tab Simple/Profile entry、Profile→preset graph、canvas 一体化、terrain promote、graph-less selected layer の UI button bootstrap、Simple Generate の viewport projection / Apply-Revert pending state
- `tests/test_generation_promote.gd`
  - Generation Graph output の Document promote、generated層置換、manual層保持、overlay/object/terrain role、save/load roundtrip、Build screen vertical slice、Build context bootstrap、top Generate の new/selected HexTileMapLayer viewport projection、Apply/Revert preview contract
- `tests/test_hex_adapter.gd`
  - canonical resource adapter、save/load roundtrip、validation エンジン、依存解決、プロファイル検証
- `tests/test_hex_tile_map_layer.gd`
  - 表示適用、座標変換、ヒット/undo、編集同期、runtime/path 反映
- `tests/test_editor_plugin.gd`
  - Workspace 各タブ（Build/Paint/Catalog/Layers/Resources/Validate/QA/Export/Settings）の screen contract
  - state snapshot / 画面責務分離 / seed lab / preview / validation issue / export handoff
- `tests/test_editor_paint.gd`
  - Paint の brush workspace、context chips、shape controls、empty CTA、viewport selected cell / last edit 同期
- `tests/test_workspace_layout_metrics.gd`
  - Workspace snapshot 収集とシーン解像度差分、JSON serialization
- `tests/test_workspace_layout_metric_evaluator.gd`
  - WARN/P0/P1 評価ルールの整合性（P1・P0 は当面 report 側）
- `tests/test_workspace_layout_metric_gate.gd`
  - `tools/test.sh` の P0 fail=0ゲート
- `tests/test_debug_scenes.gd`
  - デバッグシーンの状態切替、runtime query、toric/ループ表示の視覚検証

## 4) 運用上のログ更新

新規テストを追加するたびに、以下を更新する。  

1. 本ログ（大きい変更や新規契約）は `docs/development_log/...` の該当日付/カテゴリへ追記  
2. `docs/policy/TEST_DESIGN_POLICY.md` の責務更新（必要時）  
3. `docs/TEST.md` の実行手順が変更されていないか確認  

```text
更新順: 実行ログ（本ファイル） -> POLICY -> TEST.md
```
