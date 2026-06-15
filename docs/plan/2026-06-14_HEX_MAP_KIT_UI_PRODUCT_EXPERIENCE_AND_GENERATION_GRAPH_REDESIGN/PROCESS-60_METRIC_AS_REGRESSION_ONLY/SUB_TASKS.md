# PROCESS-60 SUB_TASKS

Complexity class: **C2**（policy/process の規則調整。docs のみ。）

## Task Resolution
UI layout metric（label count / scroll / no-op 等）を **回帰検知の補助**へ正式に降格し、UI/graph task の**合格根拠は experiential DoD**（work surface / primary action / context chips / preview の有無）であると policy/process に明記する。ADOPT-00 の gate を metric policy 側にも反映。

## Scope
含む: metric policy の位置づけ更新、合格根拠＝experiential DoD の明記。
含まない: metric ツール自体の削除（回帰として残す）。

## Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| metric | A: 回帰検知のみ / B: 合格根拠 | **A** | 前回失敗（proxy が製品目標を上書き）の是正 |
| 削除 | A: 残す(回帰) / B: 撤去 | **A** | 回帰検知の価値は本物 |

## Scheduled Task Audit: なし。
## Sub-tasks
1. `UI_LAYOUT_METRIC_..._POLICY` に「回帰検知のみ・合格根拠にしない」を明記。
2. 合格根拠＝experiential DoD（QUEUE_OPERATION_RULES two-layer gate）参照を追記。
3. test.sh の metric は回帰扱いである旨を docs に反映。
fallback/mirror: なし。
