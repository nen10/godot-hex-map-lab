# TEST_DESIGN_POLICY.md

## 目的

自動テストを、実装完了判断に使える Test path として設計するための方針を定める。

## CLEAN roadmap priority

CLEAN roadmap では `UX合理性` を優先し、headless test や compatibilityは優先度を検討しない。
自動テストは clean UX / clean API の完了判断を支えるためのものであり、旧 UI widget、path text、fallback、migration wording を保存する根拠にしない。
旧 headless test が clean UX を妨げる場合、削除または新UXの state contract へ書き換える。

## 並列実行設計

テスト効率を上げるため、複数の Godot headless process で同時実行できるテストを配置する。以下に留意する。

- 実行ログは `.godot_user/test-runs/<run-id>/logs/` に保存する。
- テストが resource を保存する場合、固定パスを直接使わず、script ごとの helper で `res://.godot_user/test-runs/<run-id>/<script-name>/` 配下へ保存し、出力の衝突を避ける。並列実行を保証し、効率化する目的。


## UI headless test

- 責務: UI headless test は、UX 文書や実装計画にあるユーザー目的に接続する状態遷移を検証する。

UX に接続する UI テストケースを作成する。
画面配置、視認性、操作感、viewport hit の自然さは、headless test の責務ではない。ユーザー確認事項として分離する。
UI 周辺の互換性や Godot 固有制約を守る technical regression guard は、UX workflow test と区別して扱う。
path `LineEdit` の存在、内部ノード名、numeric fallback control など、旧UIの実装詳細だけを headless test の期待値にしない。


## Core / Adapter test 

- 責務: Core、Adapter、Layer の test は、UX と独立した機能契約を検証し、機能の汎用性をメンテナンスする。

## Debug scene test

- 責務: debug scene test は、debug scene の表示対象データと状態切替が壊れていないことを headless で確認する。
- 視覚的な配置、操作感、viewport hit の自然さは、debug scene のユーザー実行, analog test の観察事項として扱い、自動テストから分離する。


## テスト追加

`docs/TEST.md` の Test path と概要を更新する。


## 完了判定

実装完了の主な根拠は `docs/TEST.md` の Test path と `tools/test.sh` の結果に基づく。必要な場合は debug scene ユーザー実行または analog test を追加候補として記録する。
CLEAN UI再編中は新規analog testを作らない。必要な観察項目は deferred として記録し、UI改善後のユーザー指示で再開する。
