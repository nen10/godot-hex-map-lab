# DESIGN-10 SUB_TASKS

Complexity class: **C3**（6画面の design artifact。code/state machine なし。fallback/mirror なし。各画面 normal+empty の2状態。）

## Task Resolution

`docs/policy/LAYOUT_SKETCH_POLICY.md` に準拠した **wireframe 一式**を `WIREFRAMES.md` に作る。対象は背骨中心タブ＝**Build / Paint / Export + 支援 Catalog / Layers / Resources**。各タブの「主役 work surface / context chips / primary action / empty CTA / resource 退避先 / inspector(条件付)」は本 plan（`IMPLEMENTATION_PLAN.md` の per-tab 仕様）で**確定済み**。Codex は ASCII 描画と normal+empty 展開に専念する。

**QA / Validate は park（対象外）**。Settings は DESIGN-10 対象外（後続で utility 最小適用）。

## Locked decisions（既に確定。再検討しない）

| 論点 | 決定 |
|---|---|
| Build 内部 | graph canvas 単一 + 「simple は preset graph」（mode 切替にしない） |
| Paint と viewport | 主編集は Godot main viewport、dock は palette/status |
| Catalog 範囲 | tile と object を1つの visual asset board に統合 |
| QA/Validate | tab bar から外し Diagnostics drawer（park）。wireframe 対象外 |
| 主役の支配度 | 質的（dominant かつ resource 詳細より前）。数値で縛らない |

## Scheduled Task Audit

scheduled task 追加: なし。

## Sub-tasks

1. `WIREFRAMES.md` のヘッダ（参照 policy / 凡例）。
2. Build wireframe（normal + empty）。
3. Paint wireframe（normal + empty）。
4. Export wireframe（normal + empty）。
5. Catalog wireframe（normal + empty）。
6. Layers wireframe（normal + empty）。
7. Resources wireframe（normal + empty）。
8. 各 wireframe に LAYOUT_SKETCH_POLICY §6 チェックリストの自己確認を付す。

fallback / mirror 有無: なし。
