# Roadmap Decision Policy

## Purpose

feedback、評価結果、承認済みブレスト項目群から、実装へ進める Roadmap を作成する指針を定める。

この文書は Roadmap を実行する process ではない。実行は `docs/process/`、queue 化は `IMPLEMENTATION_QUEUE_DESIGN_POLICY.md` に委ねる。

## Inputs

Roadmap 作成時は、必要に応じて以下を読む。

- 最新 feedback / 設計指針。
- 承認済みブレスト / UX roadmap。
- 直近の実行評価、self-review、risk register。
- 現在のコード・tests・manual の実態。


## Output

```text
docs/plan/<YYYY-MM-DD>_<ROADMAP_ID>/UX_ROADMAP.md
```

Roadmap は目標となる複数のUX,API方針に対して、説明可能な実施順序を設計する。

1. 目的。
2. 採用する UX / API 方針。
3. 廃止・保留する方針。
4. phase 構成。
5. phase ごとの成果物と成功状態。
6. 最初に queue 化すべき範囲。

## Decision rules

- スケールの大きな UX 提案 / ブレスト項目 / feadback項目 を元に検討する。
- ゲーム開発者の作業目的から逆算する。
- Core の安定性は保証されており、提示層の改善を目的として UI / API を破壊的に再設計してよい。
- 未公開 addon では、互換性維持を roadmap のデフォルト要件にしない。
- path text、raw JSON、numeric fallback、legacy migration wording を通常 UX の根拠にしない。
- headless test に合わせて UX を決めない。必要なら test reset を roadmap に含める。
- analog test はユーザーが指示した場合に roadmap に入れる。

## Phase design

Phase は、ユーザー価値と依存関係で切る。

良い phase:

- canonical Resource / API を先に整える。
- Resource reference / Catalog / Object identity を UI より先に整える。
- UI screen は作業目的ごとに切る。
- Test / manual / package は採用 UX が見えた後に整える。

悪い phase:

- ファイル行数を減らすだけの phase。
- 旧 UI 互換だけを守る phase。
- test 可能性を UX より優先する phase。
- 承認済み UX を再承認待ちに戻す phase。

## Roadmap review checklist

- Roadmap は feedback の要点に答えているか。
- 採用 / 廃止 / 保留が明確か。
- 実装順序の理由が依存関係または UX 価値で説明できるか。
- Roadmap に process 手順や queue status 管理を書き込んでいないか。
- 次に queue 化できる範囲が明確か。
