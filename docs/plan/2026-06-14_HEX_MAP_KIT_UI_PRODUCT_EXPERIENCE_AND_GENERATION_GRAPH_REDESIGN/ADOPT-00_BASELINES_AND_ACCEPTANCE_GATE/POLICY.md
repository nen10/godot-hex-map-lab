# ADOPT-00 POLICY

採用する規則:
- **Two-layer DoD gate**: UI/graph task の `COMPLETE` は structural DoD（構造・型・test）と experiential DoD（最初に見えるもの / 触れる primary action / graph は chain が通る）の両方を要求する。`label-heavy but metrics pass` は不可。metric は回帰検知補助で単独の合格根拠にしない。
- **QA / Validate park**: 製品目標でない。中心化・他 tab への波及を proof/acceptance の根拠にしない。自律的存続・改修は可。

Fallback / Mirror Handling: none（このtaskは fallback/mirror を導入しない）。

State / Invariant:
- 不変条件: 既存の status 語彙（`QUEUE_OPERATION_RULES.md`）を変更しない。gate は新規 acceptance 要件の**追加**であり、既存 task の status を遡及変更しない。

baseline 整合: `docs/design/PRODUCT_DEFINITION.md` §0/§7、`docs/design/GENERATION_GRAPH_MODEL.md` に準拠。
