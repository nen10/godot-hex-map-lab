# Domain Policy

## Purpose

Hex Map Kit の設計判断における上位原則と、開発領域ごとの責務境界を定める。

## Top principles

- ゲーム開発上の UX合理性を UI / API 設計の根拠にする。
- addon は未公開であり、互換性維持はデフォルト要件ではない。
- Core の本質機能は安定している。主な改善対象は提示層、Resource/API、Editor UX である。
- UI 層は破壊的に変更してよい。古い headless test が悪い UI を固定する場合、その test を更新または削除する。
- No sample-only completion: sample preset だけで成立する editor-facing 機能は `sample-only prototype` と分類し、production feature completion とは扱わない。
- production feature completion は、任意 project asset selection または明示的な未設定/validation state を持つことで判断する。bundled sample は learning / onboarding path であり、silent default ではない。
- コードベースやドキュメント記載の fallback / hack / legacy は仕様根拠にしない。
- manual は仕様書ではなく、採用済み UX を使うための説明である。


## Domain boundaries

| 領域 | 責務 | 判断基準 |
|---|---|---|
| Core | Hex 座標、map data、generation、query などの構造的機能。 | 汎用性と正確性。UI で使わない実行パスも価値があれば保持できる。 |
| Resource / API | ゲーム開発者が保存・参照・再利用する contract。 | canonical schema、typed resource、明確な責務。v1/v2 互換語彙を増やさない。 |
| Adapter | Core / Resource と Godot scene / TileMapLayer / UI を接続する。 | UI に raw 内部値を露出させず、変換責務をここに置く。 |
| UI | ユーザーの作業目的を表示・操作へ変換する。 | project asset selection を主導線にし、sample は明示的な learning / onboarding path に隔離する。path text、raw JSON、numeric fallback を通常導線にしない。 |
| Tests | 採用した UX / API が壊れていないことを確認する。 | test しやすさで UX を歪めない。sample preset success だけで feature complete と判定しない。 |
| Docs | 判断、使い方、完了根拠を残す。 | policy / process / plan / review / manual の責務を混ぜない。 |

## Documentation boundaries

- `policy`: 判断基準。
- `process`: 実行手順。
- `plan`: 個別 task の設計と実装計画。
- `review`: 実行後の評価、根拠、不足。
- `manual`: ユーザーが使うための説明。
- `tests/analog_test`: ユーザー指示がある場合の操作観察手順。CLEAN UI 再編中は新規作成しない。
