# REPAIR-13 Graph-wide state と Filter分離 Sub Tasks

日付: 2026-06-22
状態: documentation draft
前提: `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY`

## Complexity

Class: C5

Reason:
- Generate/Apply/Revert、dirty/runnable、param propagation、filter split、Source typing、Result contractが連動する。
- このまま単一patchへ進むと proof が曖昧になるため、`REPAIR-13A` などへ task 分離する。
- dynamic node graph 全体を固定FSMにせず、derived state evaluatorとして設計する必要がある。

Required artifacts:
- `SUB_TASKS.md`
- `UX.md`
- `POLICY.md`
- `STATE_MODEL.md`
- `GENERATE_PREVIEW_STATE_MODEL.md`
- `PARAM_PROPAGATION_AUDIT_MATRIX.md`
- `SOURCE_AND_FILTER_SPLIT.md`
- `NODE_ADD_ROW_AND_PORT_CONTRACT.md`
- `IMPLEMENTATION_PLAN.md`

## task境界

このtaskは、Build graphを「動的node graph」として扱いながら、設定値伝達、dirty/runnable判定、Generate/Apply/Revert、Terrain/Overlay Filter分離を一貫して設計する。

ここでは実装しない。まず日本語設計文書を作成し、未決事項を明確にする。

## 今回作成する文書

- [STATE_MODEL.md](./STATE_MODEL.md)
  - 動的graphに対するstate管理方針。
  - 巨大なFSMではなく、graph構造から導出するderived stateとして管理する。
- [PARAM_PROPAGATION_AUDIT_MATRIX.md](./PARAM_PROPAGATION_AUDIT_MATRIX.md)
  - 全node / 全paramについて、UIからrunner、output、viewportまで伝達されるか確認するmatrix。
- [GENERATE_PREVIEW_STATE_MODEL.md](./GENERATE_PREVIEW_STATE_MODEL.md)
  - `Generate -> Apply -> Generate`で初めてviewport表示される現象を失敗caseとして定義する。
  - Generate、Apply、Revert、projection failureの状態遷移を定義する。
- [SOURCE_AND_FILTER_SPLIT.md](./SOURCE_AND_FILTER_SPLIT.md)
  - `Source`をtyped sourceとして扱う設計。
  - `Region Filter`を`Terrain Filter` / `Overlay Filter`へ分離する設計。
- [NODE_ADD_ROW_AND_PORT_CONTRACT.md](./NODE_ADD_ROW_AND_PORT_CONTRACT.md)
  - node追加rowの分類。
  - `Source Terrain` / `Source Overlay`分離、`Result`の複数overlay入力、`Compose`非primary化を定義する。
- [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md)
  - state evaluator、param audit、filter split を実装へ進める前の計画。

## repair-nowではなく設計が必要な理由

- nodeは動的に増減するため、graph全体を固定FSMとして列挙する方式は破綻する。
- 設定値がUIに見えていても、runnerへ伝達されているとは限らない。
- `Source`が「何でも入る」nodeに見えるままでは、Terrain/Overlay Filter分離後の接続意味が曖昧になる。
- `Generate -> Apply -> Generate`で表示される現象は、preview stateとviewport projection stateが混ざっている可能性がある。

## completion proof方針

実装時の完了証明には、以下が必要。

- 全paramのUI -> graph params -> graph resource -> runner -> output -> viewportの伝達test。
- `Shape`の値変更が、生成cell数またはboundsに反映されるtest。
- `Generate`単体でviewport projectionが成功するtest。
- `Apply`がviewport表示の発生源になっていないことのtest。
- `Source`の出力型とFilter入力型の整合test。
- Terrain Filter / Overlay Filterの接続可否と出力selectionのtest。

## 実装前の未決事項

- `Source Terrain` / `Source Overlay`をUI buttonだけでなくnode titleでも分けるか。
- 内部modelをtyped Sourceのままにするか、node type自体も分けるか。
- `result`を再利用したい場合、`Result` inputではなく`Extract Terrain` / `Extract Overlay`またはSource変換として扱うか。
- `Region Filter`を即廃止するか、互換aliasとして一時的に残すか。
- Overlay Filterのitem-key候補をどの段階で導出するか。
- Resultの複数overlay inputを明示slot方式にするか。
- graph-wide state evaluatorをどのclassに置くか。
