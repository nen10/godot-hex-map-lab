# CLEAN-00 UX

作成日: 2026-06-07
Roadmap: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/UX_ROADMAP.md`
Queue: `docs/plan/2026-06-07_UX_FIRST_CLEAN_SPEC_ROADMAP/IMPLEMENTATION_QUEUE.md`

## 目的

今後の Autopilot run で、未公開 addon の clean spec roadmap を互換性維持や古い headless test 保護より優先できるようにする。

## Operation Steps

1. Codex は CLEAN queue の先頭 `READY` task を選ぶ。
2. Codex は roadmap の clean UX / clean API / clean test 方針を、その task の設計判断の上位規則にする。
3. 旧互換や fallback が task acceptance と衝突した場合、Codex は互換を守らず、clean spec へ置き換える。
4. 古い headless editor test が path text、fallback UI、legacy wording を固定している場合、Codex は test を削除または新 UX の state contract へ書き換える。
5. Codex は新規 analog test を作らず、UI 再編後にユーザー指示があるまで deferred として扱う。
6. Codex は self-review で「既存 test を守るために UX を歪めたか」を確認する。

## UX 評価

| 操作 | 評価 | 目標 |
|---|---|---|
| clean roadmap の `READY` task を実装する | 有用 / 維持 | 先頭 `READY` を機械的に選ぶ |
| 互換性維持を常に優先する | 不要 / 廃止 | current CLEAN task が明示する場合だけ例外にする |
| path text や fallback UI を headless test のために残す | 不要 / 廃止 | test を新 UX に合わせる |
| analog test pack を今すぐ作る | 不要 / 廃止 | CLEAN-52 で deferred marker を明記する |
| NEXT-04 manual update | 有用 / 追加 | CLEAN-40 として manual 更新へ置き換える |
| NEXT-05 file-size containment | 有用 / 置換 | CLEAN-30/31/32/33 の UX 情報設計へ置き換える |

## 不変条件

- Core / Adapter / Resource validator の機能契約は、自動テストで確認する。
- `./tools/test.sh` は completion proof の標準実行として維持する。
- public release upload、外部認証、repository 外の破壊的操作は Autopilot の通常 loop に含めない。

## 干渉する既存 UX

- v1/v2 migration、catalogless numeric fallback、path LineEdit を通常操作として扱う旧 UX は、後続 CLEAN task の削除対象である。
- 旧 manual / API wording は、CLEAN-40 / CLEAN-41 で clean vocabulary へ置換する。
- 既存 analog test は history として残せるが、clean UX acceptance の根拠にしない。
