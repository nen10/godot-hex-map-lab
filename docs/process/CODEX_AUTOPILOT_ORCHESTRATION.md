# Codex Autopilot Orchestration

作成日: 2026-06-06  
対象: Hex Map Kit roadmap implementation  
目的: validate 済み UX ロードマップを、人間の毎回承認ではなく、テスト要件・レビュー修正・キュー更新によって Codex が連続実装するための実行設計を定める。

---

## 0. 前提

このプロセスは、以下を前提にする。

1. `UX_ROADMAP.md` は validate 済みである。
2. `QUEUE.md` は、ロードマップを Codex が実装できる単位へ分割した実行キューである。
3. ユーザーの毎回承認をゲートにしない。
4. ゲートは、計画文書の閉じ方、Test path、`tools/test.sh`、self-review、fix loop によって置き換える。
5. Codex は、計画文書作成・実装・テスト追加・レビュー・不足修正・キュー更新までを同一の自走ループとして扱う。

重要な設計判断:

- Plan は「承認待ち成果物」ではなく「実装前に Codex が自分の判断を固定する作業メモ」である。
- Review は「人間に聞く場所」ではなく「テスト不足・schema debt・回帰リスクを repair queue へ戻す場所」である。
- Human validation は release 判断、UX 方向転換、外部認証・配布・破壊的削除などの例外だけに使う。

---

## 1. 目的の一文

Codex は、ロードマップキューから最初の `READY` task を選び、必要な plan files を生成または更新し、実装し、テストを通し、self-review で不足を拾い、修正し、task を `COMPLETE` にして、次の `READY` task へ進む。

```text
Roadmap
  -> Autopilot Queue
    -> Task Packet
      -> Plan Synthesis
        -> Implementation
          -> Verification
            -> Self Review
              -> Repair Loop
                -> Queue Update
                  -> Next Task
```

---

## 2. 成果物と置き場所

### 2.1 入力

| 種別 | path | 役割 |
|---|---|---|
| UX roadmap | `docs/plan/<date>_<roadmap_id>/UX_ROADMAP.md` | validate 済みの UX / phase / priority source |
| Autopilot queue | `docs/plan/<date>_<roadmap_id>/IMPLEMENTATION_QUEUE.md` | 実装単位と依存関係 |
| Policy | `docs/policy/*.md` | 設計・実装・テスト方針 |
| Test index | `docs/TEST.md` | 完了根拠になる Test path |
| Root instruction | `AGENTS.md` | Codex の入口指示 |
| Codex skill | `.agents/skills/hex-map-codex-autopilot/SKILL.md` | Codex app / CLI 用の再利用可能な実行手順 |

### 2.2 task ごとの出力

各 task は必要に応じて `docs/policy/PLANNING_POLICY.md` を参照し、以下を作る。

```text
docs/plan/<date>_<roadmap_id>/<TASK_ID>_<slug>/
  UX.md
  POLICY.md
  IMPLEMENTATION_PLAN.md
  TEST_PLAN.md                 # 大きい task の場合のみ分離してよい

docs/review/autopilot/
  <TASK_ID>_SELF_REVIEW_<date>.md
  <TASK_ID>_TEST_RESULT_<date>.md
  <TASK_ID>_REPAIR_LOG_<date>.md
```

既存方針に従い、Test path で確認できた task の plan は `docs/complete_on_test/` へ移動してよい。ただし、Autopilot queue には `COMPLETE` として残し、どの Test path で確認したかを書く。

---

## 3. 状態モデル

### 3.1 task status

| status | 意味 | 次の遷移 |
|---|---|---|
| `BACKLOG` | 依存が未完了。まだ選ばない。 | 依存完了後 `READY` |
| `READY` | 依存が満たされた。Codex が次に実装してよい。 | `RUNNING` |
| `RUNNING` | Codex が作業中。 | `VERIFYING` |
| `VERIFYING` | テスト・lint・self-check 中。 | `REPAIR_NOW` / `REVIEWING` |
| `REPAIR_NOW` | acceptance を満たさない不足がある。人間に聞かず修正する。 | `VERIFYING` |
| `REVIEWING` | diff と test coverage を self-review する。 | `REPAIR_NOW` / `COMPLETE` |
| `COMPLETE` | Test path と review を通過。次 task へ進める。 | なし |
| `COMPLETE_WITH_BACKLOG` | acceptance は満たすが、非blocking follow-up がある。 | follow-up task を追加 |
| `BLOCKED_BY_TEST_ENV` | Godot 実行環境などが欠け、検証不能。 | 環境復旧後 `VERIFYING` |
| `SPLIT_REQUIRED` | task が大きすぎて acceptance が曖昧。 | 子 task を queue に追加 |
| `SUPERSEDED` | 後続判断で別 task に吸収された。 | なし |

### 3.2 修正分類

Self-review と test failure で見つけた不足は、以下に分類する。

| 分類 | 扱い |
|---|---|
| `repair-now` | acceptance、schema migration、existing tests、主要UXに関わる。次 task へ進まず同 task 内で修正。 |
| `follow-up-ready` | 現 task の acceptance には不要だが roadmap に必要。queue へ `READY` または `BACKLOG` で追加。 |
| `known-env-failure` | Godot binary 欠落など環境起因。`BLOCKED_BY_TEST_ENV` として記録。 |
| `accepted-risk` | 仕様上許容する一時状態。理由と解除条件を review に残す。 |
| `manual-optional` | 目視や操作感の確認。自動実装ループは止めない。analog test 候補へ記録。 |

`repair-now` を人間に相談してはいけない。Codex が直す。

---

## 4. Autopilot loop

### 4.1 Dispatcher

Dispatcher は、queue の先頭から以下を満たす task を選ぶ。

1. status が `READY`。
2. dependencies がすべて `COMPLETE` または `COMPLETE_WITH_BACKLOG`。
3. 同時実行中 task と主要ファイルが衝突しない。
4. より上位 phase の schema / adapter task が未完了なら、UI task より優先する。

選んだ task は `RUNNING` にする。

### 4.2 Plan Synthesis

Codex は task に `plan_dir` がない場合、以下を作る。

```text
UX.md
POLICY.md
IMPLEMENTATION_PLAN.md
```

ただしこれは人間承認待ちにしない。以下を満たしたら、そのまま実装へ進む。

- Operation Steps が roadmap の UX と一致している。
- 対象ファイル・resource schema・saved document の扱いが明記されている。
- `docs/TEST.md` の Test path へ接続している。
- 破壊的変更または migration が testable である。

計画中に UX の細部が曖昧な場合は、以下の規則で決める。

1. ユーザーの操作語彙を減らす方を選ぶ。
2. logical key / resource schema / adapter 境界を優先し、UI に生の内部値を露出させない。
3. 既存 saved `.tres` を壊す可能性がある場合、migration helper と migration test を追加する。
4. fallback / hack は仕様根拠にしない。
5. 迷った内容は `POLICY.md` に decision として固定し、実装する。

### 4.3 Implementation

Codex は `IMPLEMENTATION_PLAN.md` の番号順に実装する。ただし、テスト作成が先に必要な場合は test-first にしてよい。

実装時の必須事項:

- code と tests を同じ task 内で更新する。
- 自動テスト追加時は `docs/TEST.md` を更新する。
- saved resource schema 変更時は migration または compatibility test を追加する。
- UI 変更時は headless test または analog test 候補を追加する。
- 既存 UX の互換性を壊す場合、代替 Operation Steps を UX/POLICY に書く。

### 4.4 Verification

標準実行:

```sh
./tools/test.sh
```

必要なら targeted check を先に行う。ただし completion proof は最終的に `tools/test.sh` と Test path の説明に接続する。

テスト失敗時:

1. 失敗を `docs/review/autopilot/<TASK_ID>_TEST_RESULT_<date>.md` に記録する。
2. failure を `implementation-regression` / `test-expectation-wrong` / `pre-existing` / `environment` に分類する。
3. `implementation-regression` と `test-expectation-wrong` は `REPAIR_NOW` にして修正する。
4. `pre-existing` と判断するには、該当 task の変更と無関係である根拠を diff / log /既存文書から示す。
5. `environment` は `BLOCKED_BY_TEST_ENV` にできるが、queue は勝手に `COMPLETE` にしない。

### 4.5 Review

Codex は実装後に self-review を行い、以下を確認する。

- Roadmap acceptance を満たしているか。
- `IMPLEMENTATION_PLAN.md` の番号項目が完了しているか。
- Test path が docs/TEST.md に接続されているか。
- schema migration / saved resource compatibility が落ちていないか。
- Generate Dock / Edit Dock / HexTileMapLayer runtime helper の既存経路を壊していないか。
- object / label / overlay の payload が曖昧な Array 増築として放置されていないか。
- fallback / hack が仕様根拠になっていないか。

不足があれば分類する。`repair-now` は必ず同じ loop で修正する。

### 4.6 Queue Update

Task 完了時、queue の該当行を更新する。

```text
status: COMPLETE or COMPLETE_WITH_BACKLOG
completed_by: <date / branch / commit if available>
proof:
  - tests: <commands>
  - docs: <plan/review path>
  - files: <主要変更ファイル>
followups:
  - <追加task id or none>
```

Task を `COMPLETE` / `COMPLETE_WITH_BACKLOG` / `BLOCKED_BY_TEST_ENV` / `SPLIT_REQUIRED` / `SUPERSEDED` のいずれかで閉じたら、同じ queue update 内で dependency sweep を必ず行う。

Dependency sweep の手順:

1. queue 全体の task status を読み、`COMPLETE` と `COMPLETE_WITH_BACKLOG` だけを完了済み dependency として扱う。
2. `BACKLOG` task の `dependencies` を全件確認する。
3. すべての dependency が完了済みなら、その task を `READY` に変更する。
4. `RUNNING` / `VERIFYING` / `REPAIR_NOW` / `BLOCKED_BY_TEST_ENV` / `SPLIT_REQUIRED` / `SUPERSEDED` / `COMPLETE` / `COMPLETE_WITH_BACKLOG` は dependency sweep で別 status に変えない。
5. `READY` task の dependency が満たされていることを再確認する。満たされていない `READY` があれば、queue inconsistency として `BACKLOG` に戻し、理由を current pointer または proof log に記録する。
6. `Current pointer` は sweep 後の先頭 `READY` task と、必要なら他の `READY` task を示すよう更新する。

完了後、Dispatcher は sweep 後の先頭 `READY` task へ進む。先頭は queue 記載順を基本とし、schema / adapter foundation task が UI task と競合する場合は schema / adapter を優先する。

---

## 5. 実装単位の大きさ

この Autopilot での task は、細切れの関数修正ではなく、**テスト可能な UX slice** とする。

良い単位:

- resource schema + adapter + migration test
- catalog resource + sample resource + validation test
- dashboard UI + error focus + headless UI test
- object placement schema + object cleanup + validation test

悪い単位:

- class を1つ作るだけ
- button を1つ置くだけ
- plan だけ作って人間承認待ち
- test なしで UI だけ増やす
- schema 変更だけして migration を後回しにする

中断点は人間承認ではなく、以下に置く。

- Test path が通る。
- Review が `repair-now` を残していない。
- Queue の次 task が機械的に選べる。

---


## 6. 停止条件

Autopilot が止まってよいのは以下だけである。

1. `BLOCKED_BY_TEST_ENV`: Godot binary 欠落など、実行環境がなく completion proof を作れない。
2. `external-secret-required`: 外部サービス認証、秘密情報、配布署名が必要。
3. `unsafe-destructive-action`: repository 外の大量削除、ユーザー環境破壊の可能性がある。
4. `release-human-check`: public release / asset library package の公開直前。
5. `roadmap-contradiction`: validate 済み roadmap 内で同時に満たせない UX が発見され、testable な折衷案を作れない。

上記以外は、Codex が方針を決めて docs に残し、実装する。

---

## 7. 完了条件

1 task の `COMPLETE` 条件:

- queue の acceptance を満たす。
- code / docs / tests が更新されている。
- `docs/TEST.md` の Test path に接続されている。
- `tools/test.sh` の結果が記録されている。
- self-review があり、`repair-now` が残っていない。
- follow-up がある場合は queue に task として追加されている。
- queue の dependency sweep が実行され、依存が満たされた `BACKLOG` task が `READY` になっている。

Phase の `COMPLETE` 条件:

- Phase 内の required task がすべて `COMPLETE` または `COMPLETE_WITH_BACKLOG`。
- その phase の public UX path が headless test または analog test 候補で説明されている。
- 次 phase の最初の task が `READY` になっている。

Roadmap の `COMPLETE` 条件:

- Phase 1〜7 の required task が完了。
- package / examples / migration guide が通る。
- public release check のみ人間確認へ渡す。

---

## 8. 判断規則

Codex は UX 設計に基づき任意に自動判断して計画を立て実装する。

- implementation plan の内部順序。
- resource field の編集。
- UI label の初期案。
- adapter helper の分割。
- test fixture の追加。
- review で見つけた不足の repair。
- follow-up task の queue 追加。
- 公式ドキュメント等調査

Codex が避ける判断:

- roadmap priority の大幅変更。
- public package release の実行。
- external service / credential の利用。

---

Skill は task ループの入口を短くするためのもの。queue と orchestration doc が source of truth である。
