

## 自動テスト

```sh
./tools/test.sh
```

`tools/test.sh` は `tools/package_addon.sh --check` で package manifest を検証してから Godot headless tests を実行します。

複数 test script を並列実行する場合:

```sh
TEST_JOBS=3 ./tools/test.sh
```

Godot の実行ファイルを明示する場合:

```sh
GODOT_BIN=/path/to/Godot ./tools/test.sh
```

Godot が出す終了コード 0の macOS 証明書関連の非致命的な ERROR は既知であり無視します。

## Graph progress profiling

Build Graph の progress weight を設計するための生成 / visual apply timing を測る場合:

```sh
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
"$GODOT_BIN" --headless --path . --script tools/profile_graph_progress_weights.gd -- --run-id=manual-graph-progress
```

結果は次に出力されます。

```text
.godot_user/perf/graph-progress/<run-id>/graph_progress_profile.json
.godot_user/perf/graph-progress/<run-id>/graph_progress_profile.md
```

## Addon package

addon-only zip と manifest を生成する場合:

```sh
./tools/package_addon.sh
```

manifest check だけ実行する場合:

```sh
./tools/package_addon.sh --check
```

## ChatGPT への引き渡し用 zip

現在の作業ツリーを zip 化する場合:

```sh
./tools/export_chatgpt_zip.sh
```

出力先を指定する場合:

```sh
./tools/export_chatgpt_zip.sh /tmp/godot-hex-map-lab-chatgpt.zip
```

この script は未コミット・未追跡ファイルを含め、`.git/`、`.godot/`、`.godot_user/`、debug 生成物などのローカル生成物を除外します。IDE 上の未保存変更は含まれないため、必要なファイルを保存してから実行してください。
