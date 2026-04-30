
# TEST.md


## 管理

(コマンド実行のみで完了する)テスト作成時、`tools/test.sh` を合わせて更新する
intaractiveなテスト作成時、実行方法をdocumentationする

### Test path

- `tests/test_hex_core.gd`
- `tests/test_hex_map_generation.gd`
- `tests/test_hex_adapter.gd`


## 実行

```sh
./tools/test.sh
```

Godot の実行ファイルを明示する場合:

```sh
GODOT_BIN=/path/to/Godot ./tools/test.sh
```

Godot が出す終了コード 0の macOS 証明書関連の非致命的な ERROR は既知であり無視します。
