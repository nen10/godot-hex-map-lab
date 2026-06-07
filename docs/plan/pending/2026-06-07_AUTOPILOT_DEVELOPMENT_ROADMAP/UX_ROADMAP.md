# Autopilot Development Roadmap 2026-06-07

作成日: 2026-06-07  
Source review: `docs/review/AUTOPILOT_DEVELOPMENT_EVALUATION_2026-06-07.md`  
Queue: `docs/plan/2026-06-07_AUTOPILOT_DEVELOPMENT_ROADMAP/IMPLEMENTATION_QUEUE.md`  
対象: Autopilot 後の Hex Map Kit v0.3 仕上げ、画面UX、配布前品質、保守性

---

## 0. 結論

Autopilot 実装は、Level Document v2、catalog key、layer stack、validation、runtime query、object placement、generation QA、package script の設計を成立させた。次の開発は設計のやり直しではなく、**公開前のUX仕上げ** と **配布物の整合性固定** を中心に進める。

この roadmap は、評価で見つかった不足を以下の順で閉じる。

1. sample catalog / package / dist の破損リスクを先に直す。
2. 新機能の画面操作手順と analog test を揃える。
3. Catalog、Layer Stack、Validation、Object、Generation QA を screen workflow として磨く。
4. public API の accident point と巨大 editor file の成長を抑える。
5. CI / release gate で配布前品質を固定する。

---

## 1. 開発要件

| id | priority | 要件 | 根拠 | 完了基準 |
|---|---:|---|---|---|
| `REQ-PKG-01` | P0 | sample catalog が package 内に存在する scene / resource だけを参照する。 | `object.spawn_marker` の scene path が見つからない評価結果。 | validator clean、missing scene なし、package check PASS。 |
| `REQ-PKG-02` | P0 | committed `dist` が現在の addon tree と一致する。 | committed manifest と一時生成 manifest の entry 数差分。 | dist 再生成、freshness check、release check PASS。 |
| `REQ-UX-01` | P0 | 新機能に analog test を追加する。 | headless coverage は強いが画面確認手順が不足。 | 主要6 workflow の Operation Steps / Expected Observations / Failure Signals / Evidence To Attach がある。 |
| `REQ-UX-02` | P1 | manual を v0.3 の目的別 workflow へ更新する。 | 既存 manual は新機能の画面操作を十分に説明しない。 | Catalog、Layer Stack、Validation、Object、Generation QA、Package install が目的別に説明される。 |
| `REQ-UX-03` | P1 | Resource/API 実装済み機能を screen workflow として完成させる。 | Catalog UI、Layer Stack、Object Property Editor、Generation QA は API が先行している。 | Editor 上で数値内部値を主導線にせず操作でき、headless / analog test に接続する。 |
| `REQ-API-01` | P2 | v2 canonical mutation path と validation issue helper を厚くする。 | v1/v2 二重管理と Dictionary issue schema が事故点になりやすい。 | UI が raw Dictionary key や legacy field を直接組み立てない。 |
| `REQ-ARCH-01` | P2 | 巨大 dock / 巨大 editor test の成長を止める。 | `hex_map_gen_dock.gd`、`hex_map_edit_tool.gd`、`test_editor_plugin.gd` がさらに肥大化。 | 新規 panel / test は feature-specific file へ分離される。 |
| `REQ-CI-01` | P2 | package / test / dist freshness を CI または release gate に固定する。 | 手元評価環境では Godot がなく、PASS記録と配布物の freshness が分離している。 | Godot headless、package check、dist freshness、sample catalog clean validation が一つの gate で実行できる。 |

---

## 2. 完了判定の成熟度

既存 task status は queue の実行状態を表す。以後の roadmap では、実行 status とは別に、完了証跡の成熟度を明示する。

| maturity | 意味 | 使用場面 |
|---|---|---|
| `CODE_COMPLETE` | code / resource / docs の実装が存在する。 | API や helper の最初の到達点。 |
| `HEADLESS_TEST_COMPLETE` | `./tools/test.sh` または対象 test path が通る。 | 自動実装 task の基本完了。 |
| `EDITOR_WORKFLOW_COMPLETE` | Godot Editor 上の画面操作導線が成立している。 | Catalog / Validation / Object / Generation QA などのUI機能。 |
| `ANALOG_TEST_COMPLETE` | 手動操作手順と観察点が docs/TEST.md から辿れる。 | headless では見えないUX確認。 |
| `PACKAGE_READY` | addon-only package を clean project に入れて破綻しない。 | public release 前。 |

User-facing UX task は `HEADLESS_TEST_COMPLETE` だけでは閉じない。画面で触る機能は `EDITOR_WORKFLOW_COMPLETE` と `ANALOG_TEST_COMPLETE` を completion proof に含める。

---

## 3. Phase Roadmap

### Phase 0: Package Integrity Repair

目的:

- 初回ユーザーが sample catalog / package / dist で壊れた体験を踏まない状態にする。

対象要件:

- `REQ-PKG-01`
- `REQ-PKG-02`

成果物:

- package 内に存在する sample object scene または sample catalog の参照修正。
- sample catalog clean validation test。
- dist 再生成。
- dist freshness check。

完了条件:

- `tools/package_addon.sh --check` が PASS。
- sample catalog の missing scene error が 0。
- committed `dist` と再生成 manifest の差分がない。

### Phase 1: UX Evidence Pack

目的:

- 自動テストで見えない画面UXを、analog test と manual で観察可能にする。

対象要件:

- `REQ-UX-01`
- `REQ-UX-02`

成果物:

- Validation Dashboard cell focus analog test。
- Catalog selector and tile preview analog test。
- Layer Stack workflow analog test。
- Object placement editor analog test。
- Generation QA / Seed promotion analog test。
- Clean package install analog test。
- `docs/TEST.md` からの参照。
- `MANUAL_EDITOR_PLUGIN.md` の v0.3 workflow 更新。

完了条件:

- 主要 workflow ごとに Operation Steps、Expected Observations、Failure Signals、Evidence To Attach がある。
- manual が機能列挙ではなく目的別操作手順として読める。

### Phase 2: Screen Workflow Completion

目的:

- Resource/API と headless test で成立した機能を、Editor 上で迷わず使える screen workflow にする。

対象要件:

- `REQ-UX-03`
- `REQ-API-01`

対象 workflow:

1. Catalog / Layer Stack
2. Validation Dashboard
3. Object Property Editor
4. Generation QA / Seed Lab

完了条件:

- `source_id / atlas_coords` は advanced fallback として扱われ、catalog key が通常導線になる。
- validation issue から cell focus / debug report へ移動できる。
- object definition と placement の編集責務が混ざらない。
- batch generation の score table / promotion / dirty state が画面で理解できる。

### Phase 3: Architecture Containment

目的:

- screen workflow を追加しても巨大 dock と巨大 test file が増え続けない状態にする。

対象要件:

- `REQ-ARCH-01`
- `REQ-API-01`

成果物:

- Generate Dock の generation QA panel 分離。
- Edit Tool の catalog / object / validation panel 分離。
- `HexTileMapLayer` の object layer adapter / gameplay overlay painter 分離候補。
- `tests/test_editor_plugin.gd` から feature-specific tests への分割。
- validation issue helper / rule id constants。
- v2 canonical mutation helper。

完了条件:

- 新規 screen workflow の主ロジックが巨大 dock に直接追加されない。
- feature-specific tests で対象UIを確認できる。
- UI 層が raw Dictionary issue や legacy v1 field を直接編集しない。

### Phase 4: Release Quality Gate

目的:

- public package の直前に、人間確認以外の機械的 gate を揃える。

対象要件:

- `REQ-CI-01`

成果物:

- Godot 4.6.2 headless test gate。
- `tools/package_addon.sh --check` gate。
- dist freshness gate。
- sample catalog clean validation gate。
- clean project install analog test。

完了条件:

- release 前に `./tools/test.sh` と package/release check を一貫して実行できる。
- package upload だけが human release check として残る。

---

## 4. 依存関係

```text
Phase 0 Package Integrity
  ├─ sample catalog integrity
  └─ dist freshness
      ↓
Phase 1 UX Evidence Pack
  ├─ analog tests
  └─ manual workflow update
      ↓
Phase 2 Screen Workflow Completion
  ├─ Catalog / Layer Stack screen workflow
  ├─ Validation Dashboard screen workflow
  ├─ Object Property Editor workflow
  └─ Generation QA screen workflow
      ↓
Phase 3 Architecture Containment
  ├─ API hardening
  ├─ editor panel split
  └─ editor test split
      ↓
Phase 4 Release Quality Gate
```

Architecture containment は Phase 2 の後続だけではなく、巨大 file への広い追加が必要になった時点で companion task として先行できる。

---

## 5. 非目標

この roadmap では以下を扱わない。

- Level Document v2 / Catalog / Layer Stack / Validation / Runtime Query の基本設計をやり直す。
- Godot 標準 TileMap editor を完全置換する。
- public release upload を自動実行する。
- Tiled / LDtk import/export を優先実装する。
- chunk streaming / infinite map / multiplayer deterministic map へ範囲を広げる。

---

## 6. 成功条件

この roadmap が完了した状態:

- sample catalog、examples、package artifact が clean project で壊れない。
- v0.3 新機能の主要操作が manual と analog test で説明されている。
- Catalog、Layer Stack、Validation、Object、Generation QA が API だけでなく screen workflow として使える。
- 巨大 editor file への直接増築が止まり、feature-specific panel / test に分かれている。
- `tools/test.sh`、package check、dist freshness、sample catalog validation が release gate として接続されている。
