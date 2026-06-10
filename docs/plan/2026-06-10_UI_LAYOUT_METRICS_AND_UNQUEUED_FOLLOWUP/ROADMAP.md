# UI Layout Metrics And Unqueued Workspace Follow-up Roadmap 2026-06-10

作成日: 2026-06-10
対象repo: `godot-hex-map-lab`
前提roadmap: `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/ROADMAP.md`

入力feedback:

1. `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/_feedbacks/UI_LAYOUT_METRIC_TEST_PROCESS_ROADMAP_2026-06-10.md`
2. `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/_feedbacks/UNQUEUED_REQUIREMENTS_EXTRACT_2026-06-10.md`

関連policy:

- `docs/policy/ROADMAP_DECISION_POLICY.md`
- `docs/policy/IMPLEMENTATION_QUEUE_DESIGN_POLICY.md`
- `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`

目的: 完了済みの Resource / State / Workspace refactor で残った `deferred` / `future` / `mirror` / process debt を queue 化し、Workspace UI を数値・状態・構造で評価する UI Layout Metric Test を導入したうえで、次の UI / architecture / performance 改善へ進む。

---

## 0. 結論

次の実装は、すぐに大きな UI 分解へ入る前に、2つの土台を固定する。

```text
1. Deferred / future / mirror が prose に残らない process guardrail
2. Workspace UI を Godot Control tree の metric で評価する acceptance foundation
```

その後、未queue化抽出で P0 とされた実装 debt を進める。

```text
P0 implementation:
  - physical Workspace UI node construction extraction
  - Generate Dock internals split
  - Catalog editor component extraction
  - chunked TileMap apply implementation
```

UI metric は人間の見た目評価を置き換えるものではない。だが、scroll不能、no-op button、debug leakage、generic ResourcePicker、state contradiction、label truncation risk は機械的に検出できるため、今後の UI task の acceptance gate に組み込む。

---

## 1. 採用する方針

### 1.1 Process guardrail を先に置く

採用:

- task plan の complexity / candidate matrix / scheduled audit を強める。
- phase review matrix を作り、phase 終了時に prose-only defer を次 queue へ変換する。
- fallback ledger を作り、manual override / sample learning / debug detail / mirror flags を owner と removal condition 付きで管理する。
- plan と execution proof の境界を明確化する。

理由:

- `UNQUEUED_REQUIREMENTS_EXTRACT_2026-06-10.md` は、実装自体よりも「後で」が散逸したことを問題にしている。
- 大きな UI / architecture task に入る前に、分解と proof の仕組みを補強する方が再発防止になる。

### 1.2 UI Layout Metric Test を acceptance foundation にする

採用:

- `docs/ui/WORKSPACE_UI_CONTRACT.md`
- `docs/ui/WORKSPACE_STATE_MATRIX.md`
- static audit
- Godot headless layout snapshot
- warn-only evaluator
- P0/P1 gates
- `tools/test.sh` integration
- autopilot self-review template update

検出対象:

- text truncation risk
- resource row geometry
- scroll reachability
- dead area / control density
- visible debug leakage
- no-op button
- ResourcePicker type specificity
- state contradiction
- sample separation
- Generate result / document persistence clarity

### 1.3 P0 implementation debt を metric foundation 後に進める

採用:

- `ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION`
- `ARCH-NEXT-11_GENERATE_DOCK_INTERNAL_COMPONENT_SPLIT`
- `CAT-NEXT-10_CATALOG_EDITOR_COMPONENT_EXTRACTION`
- `PERF-NEXT-10_CHUNKED_TILEMAP_APPLY_IMPLEMENTATION`

理由:

- UI node construction / Generate internals / Catalog editor は first impression と保守性の両方に効く。
- chunked apply は performance budget で明確に future requirement 化された実装 debt である。
- これらは metric gate の対象になりやすいので、先に UI contract / metric foundation を整える。

### 1.4 P1/P2 debt は queue に載せるが、依存を明確にする

採用する P1 / P2 / decision task:

- Generate tab layout redesign
- Generate / QA preview thumbnails
- Catalog tile / scene preview UI
- Resources / Layers / Export visual redesign
- Layer role editor
- Paint viewport affordance polish
- Validate rich issue table actions
- QA score table visual redesign
- Settings grouping / toggle styling
- Sample detail drawer
- large-map validation progress
- GenerationResultResource / replay API
- pipeline graph UI research
- object layer rendering extraction
- gameplay query service extraction
- debug overlay renderer extraction
- editor test file split continuation
- root reducer / event model
- generation private flag mirror retirement
- concrete profile behavior schemas
- package build UI decision

---

## 2. 廃止・保留する方針

- analog test はユーザーが明示するまで作らない。
- public package upload は自動 queue に入れない。
- committed `dist` freshness は通常 test gate にしない。
- UI metric test は美的判断をしない。
- headless test に合わせて UI を歪めない。
- old UI compatibility / migration wording / path text / raw JSON / numeric fallback は通常 UX の根拠にしない。

---

## 3. Phase 構成

### Phase M0: Feedback adoption / process guardrails

目的:

- 今回feedbackを source of truth として固定する。
- deferred / rejected item が散逸しない plan/process を整える。

成功状態:

- New roadmap / queue ができている。
- complexity class / phase review / fallback ledger / plan-execution boundary が process docs と proof docs に入る。

### Phase M1: UI metric contract foundation

目的:

- Workspace UI contract と state matrix を作る。
- static audit と layout snapshot collector の前提を作る。

成功状態:

- tabごとの purpose / required components / forbidden visible text / thresholds が文書化される。
- stateごとの expected / forbidden visible state が定義される。
- static audit が P0 risk を report できる。

### Phase M2: UI metric evaluator and acceptance gates

目的:

- warn-only evaluator から P0/P1 gate へ段階移行する。
- UI task self-review が metric report を参照する。

成功状態:

- P0 failures を test gate 化できる。
- P1 は warn または個別 command から開始し、後続 task で強化できる。

### Phase M3: P0 UI architecture / performance debt

目的:

- physical UI node construction / Generate Dock / Catalog editor / chunked apply の P0 debt を解消する。

成功状態:

- Workspace host は tab host / context / dispatcher に寄る。
- Generate Dock は run/profile/preview/output component に分かれる。
- Catalog editor は list/detail/create/validate component に分かれる。
- large apply は progress / busy state と接続した chunked path を持つ。

### Phase M4: P1 screen polish and visual work surfaces

目的:

- Generate / QA / Catalog / Resources / Layers / Export / Paint / Validate / Settings / Sample をより作業画面として強める。

成功状態:

- summary-only screen ではなく、比較・選択・focus・preview・role editing が visible task surface として成立する。

### Phase M5: State / profile / generation pipeline debt

目的:

- GenerationResultResource / profile behavior schema / reducer event model / private mirror retirement / validation progress を進める。

成功状態:

- intermediate generation result と final Level Document の境界が Resource/API と UI で扱える。
- mirror flags の removal condition が queue と tests により管理される。

### Phase M6: Runtime extraction / tests / release decision

目的:

- HexTileMapLayer の runtime helper debt、test split continuation、package build UI decision、manual/final packaging を閉じる。

成功状態:

- Runtime rendering/query/debug responsibilities が分離される。
- tests は family別に分かれ、old private widget shape を増やさない。
- manual と final package が最新状態になる。

---

## 4. Feedback mapping

| feedback item | roadmap target |
|---|---|
| UI metric contract docs | `UI-METRIC-00`, `UI-METRIC-01` |
| static audit | `UI-METRIC-02` |
| runtime layout snapshot | `UI-METRIC-03` |
| warn-only evaluator | `UI-METRIC-04` |
| P0/P1 acceptance gates | `UI-METRIC-05`, `UI-METRIC-06` |
| test.sh integration / self-review template | `UI-METRIC-07`, `UI-METRIC-08` |
| process complexity / phase review / fallback ledger | `PROCESS-10`, `PROCESS-11`, `PROCESS-12` |
| plan execution boundary | `PROCESS-13` |
| physical UI node construction extraction | `ARCH-NEXT-10` |
| Generate Dock split / layout / thumbnails | `ARCH-NEXT-11`, `GEN-NEXT-10`, `GEN-NEXT-11` |
| Catalog extraction / previews | `CAT-NEXT-10`, `CAT-NEXT-11` |
| Resources / Layers / Export redesign | `SCREEN-NEXT-10`, `LAYER-NEXT-10`, `EXPORT-NEXT-10` |
| Paint / Validate / QA polish | `PAINT-NEXT-10`, `VAL-NEXT-10`, `QA-NEXT-10` |
| chunked apply / validation progress | `PERF-NEXT-10`, `PERF-NEXT-11` |
| generation result / graph | `GENPIPE-NEXT-10`, `GENPIPE-NEXT-20` |
| object / gameplay / debug overlay extraction | `ARCH-NEXT-20`, `ARCH-NEXT-21`, `ARCH-NEXT-22` |
| profile behavior schema | `PROFILE-NEXT-10` |
| root reducer / private flag mirrors | `STATE-NEXT-10`, `STATE-NEXT-11` |
| editor test split continuation | `TEST-NEXT-10` |

---

## 5. Queue 化範囲

今回の `IMPLEMENTATION_QUEUE.md` は、この roadmap 全体を queue 化する。最初の実行範囲は以下。

```text
NEXT-00_ADOPT_UI_METRIC_AND_UNQUEUED_FEEDBACKS
PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS
PROCESS-11_PHASE_REVIEW_MATRIX
PROCESS-12_FALLBACK_LEDGER
UI-METRIC-00_WORKSPACE_UI_CONTRACT
```

`NEXT-00` の完了後、先頭の `READY` task から autopilot loop で進める。
