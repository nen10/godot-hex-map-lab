# PROCESS-60 POLICY

## Adopted Decision

UI layout metric は標準テストに残すが、役割は **regression signal** とする。

Metric pass は UI/graph task の合格根拠ではない。合格根拠は `docs/process/QUEUE_OPERATION_RULES.md` の two-layer DoD、特に experiential DoD（work surface / primary action / context chips / preview の有無）である。

## Rejected Decision

Metric を UI acceptance の代理にしない。

Metric failure を無視可能な任意レポートにはしない。P0 は標準テスト上の regression failure として扱い、修正対象にする。

## Resource / API / UI Boundary

この task は process/docs の境界調整であり、Editor UI の見た目や Resource/API schema は変更しない。

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| fallback metric acceptance | reject | metric pass は proxy であり製品体験の合格根拠にならない | none | policy text |
| mirror acceptance path | reject | queue の two-layer DoD が source of truth | none | policy text |

## Completion Criteria

- `UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md` が metric を regression signal として明記する。
- `docs/TEST.md` と `tools/test.sh` の記述・コメントが「標準テストに残る regression check」と「合格根拠ではない」を矛盾なく説明する。
- `./tools/test.sh` が引き続き通る。
