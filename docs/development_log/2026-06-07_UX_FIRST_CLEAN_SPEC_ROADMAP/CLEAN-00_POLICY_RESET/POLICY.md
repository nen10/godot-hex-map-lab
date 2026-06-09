# CLEAN-00 Policy

作成日: 2026-06-07

## 採用方針

1. `UX合理性 > headless test > compatibility` を CLEAN roadmap の優先順位として固定する。
2. addon は未公開であるため、v1/v2、legacy field、fallback、path text を維持することは原則にしない。
3. compatibility は、current CLEAN task が acceptance で明示した場合だけ例外として扱う。
4. headless editor test は UX を守るための state contract であり、旧 UI widget や内部 node 名を守るための仕様ではない。
5. 古い test が clean UX を妨げる場合、test を削除または新 UX の状態遷移へ書き換える。
6. 新規 analog test は UI 再編中に作らない。必要な場合は UI 改善後にユーザー指示で再開する。
7. self-review は必ず「既存 test を守るために UX を歪めたか」を確認する。

## 不採用方針

| 候補 | 判断 | 理由 |
|---|---|---|
| 旧 `.tres` 互換を常に守る | 不採用 | 未公開 addon では clean schema の方が後続実装の価値が高い |
| headless test の既存 selector / LineEdit / fallback UI を仕様として保存する | 不採用 | テスト都合が UX を固定してしまう |
| NEXT-03 analog test pack をこの roadmap の実装前提にする | 不採用 | 現時点では UI が再編中で、印象改善前の analog test は acceptance を歪める |
| NEXT-05 を file size だけで判断する | 不採用 | UI 分割はユーザーの作業目的に基づく必要がある |

## NEXT 置換

- `NEXT-03`: scheduled work から外す。CLEAN-52 で analog test deferral marker を明記する。
- `NEXT-04`: CLEAN-40 `Manual and API docs` の manual update として扱う。
- `NEXT-05`: CLEAN-30 / CLEAN-31 / CLEAN-32 / CLEAN-33 の UX information architecture として扱う。

## Test policy

- この task は docs/policy reset であり、新しい test script は追加しない。
- `docs/TEST.md` の test path は変更しない。
- 完了 proof として `./tools/test.sh` を実行する。
- `docs/TEST.md` に analog deferral を明記する作業は CLEAN-52 に残す。

## Review policy

Self-review では以下を確認する。

- policy docs に `UX合理性 > headless test > compatibility` が明記されている。
- compatibility が例外として扱われている。
- analog test 新規作成が deferred として扱われている。
- queue の dependency sweep で `CLEAN-30` と `CLEAN-52` が `READY` になる。
- `repair-now` が残っていない。
