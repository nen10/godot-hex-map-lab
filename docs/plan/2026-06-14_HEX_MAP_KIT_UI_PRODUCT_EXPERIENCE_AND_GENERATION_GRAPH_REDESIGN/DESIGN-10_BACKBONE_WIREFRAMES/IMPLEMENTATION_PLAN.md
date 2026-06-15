# DESIGN-10 IMPLEMENTATION_PLAN（pre-execution）

## Scope

`docs/policy/LAYOUT_SKETCH_POLICY.md` 準拠の wireframe を `WIREFRAMES.md` に作る。対象6タブの**設計仕様は本書で確定**。Codex は ASCII 描画と normal+empty 展開に専念する。code 変更なし。

## 変更対象ファイル

```
docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/WIREFRAMES.md   （新規）
```

## per-tab 設計仕様（確定。これを wireframe 化する）

> 共通骨格（LAYOUT_SKETCH_POLICY §1）: `context strip(chips)+primary action` / `primary work surface(dominant)` / `selected inspector(条件付)` / `empty は CTA`。map semantics は chips、詳細は退避。

### Build（primary）
- 主役: **graph canvas（node board）** 左〜中央 dominant ＋ **output preview** 右。
- chips: `Map:` `Catalog:` `Target:(role)`
- primary action: `[Generate]`（N=1）context strip 右。
- secondary（降格・下方）: `N`(default 1) 入力 / seed・shape randomize。
- inspector（下帯）: Selected node — Inputs / Outputs / params、`[Promote output to Layer]` `[Use as Filter Input]`。
- empty: 「Start a build」→ `[New Pipeline]` `[Simple: choose Generation Profile]` `[Open sample as tutorial]`。
- 退避: 詳細 resource 選択 → Resources tab。
- 注: simple は **preset graph**（mode 切替にしない）。

### Paint（primary）
- 主役: **brush palette + 編集ステータス**（dock）。実描画は Godot main 2D viewport（dock は palette/status に専念）。
- chips: `Map:` `Layer:(active role)` `Brush:(catalog key)`
- primary action: brush 選択 + 形状行 `single / line / disc / flood`。
- status: `Cell: q,r` / `Last edit: painted N cells on <layer>`。
- empty: 「No paintable map」→ `[Create Level Document]` `[Choose Level Document]`。
- 退避: layer 詳細 → Layers、catalog → Catalog。

### Export（utility / handoff）
- 主役: **purpose cards（handoff 3形態）** dominant。
  - `Runtime Map Resource (.tres)` `[Export .tres]`（HexTileMapLayer が load）
  - `Runtime Scene (.tscn)` `[Create Scene]`（layer node tree を配置）
  - `Generation Graph (.tres)` `[Export Graph]`（runtime Map Build API 用）
  - 下段（副次）: `Debug Report` / `JSON Snapshot` / `Package`(process-only, disabled+tooltip)
- chips: `Map:`
- primary action: Runtime Map Resource card の action を頭出し。
- empty: 「Nothing to hand off yet」→ `[Build or select a map]`。
- 退避: destination path → drawer/dialog。
- 注: 「遊べる」化しない（境界 utility まで）。

### Catalog（support）
- 主役: **tile/object 統合 visual board**（entry card grid: preview+name+badge）。
- chips: `Catalog:`
- primary action: `[Add Entry]`、card 選択 → inspector。
- inspector（側）: 選択 entry — preview（tile atlas / object scene）/ tags / missing badge。
- empty: 「No catalog」→ `[Create Catalog]` `[Choose Catalog]` `[Open sample]`。
- 退避: raw source_id / atlas_coords は **tooltip**（主面非表示）、catalog 選択 → Resources。

### Layers（support）
- 主役: **role stack visual tree**（terrain/overlay/object/debug 行、各行に visible/lock/writable-source/z の chip、並べ替え可）。
- chips: `Map:` `Layer Stack:`
- primary action: `[Add Role]`、行選択 → inspector。
- inspector: 選択 role — writable source(document/target/generated/readonly) / z-index / visible / lock。
- empty: 「No layer stack」→ `[Create Layer Stack]` `[Choose Layer Stack]`。
- 退避: stack 選択 → Resources。

### Resources（support — resource が主役で良い唯一のタブ）
- 主役: **asset shelf**（3群の card: `Unique to this map` / `Shared project assets` / `Optional`、各 card=資産名+status badge）。
- chips: `Selected HexTileMap:`
- primary action: `[Create Missing Resources]`（大 CTA）+ `[Save All]`。
- empty: 「No HexTileMap selected」→ `[Select a HexTileMap node]` / 「Start a map」→ `[Create Level Document]` `[Choose Tile Catalog]`。
- 注: 現状先頭の `Readiness Summary` / `Next actions:` ラベル列を**置換**（U1/U6 是正）。

## WIREFRAMES.md の構成（Codex への描画指示）

1. ヘッダ: 参照 `LAYOUT_SKETCH_POLICY.md`、ASCII 凡例（`[Action]` / `( Key: value )` chip / 主役は最大面積 / `# 注記`）。
2. 各タブ節: `### <Tab>` に **normal** と **empty** の2 ASCII box。各 box の上に「主役 / primary action / resource 退避先」を1行明記。
3. 各タブ末尾に **LAYOUT_SKETCH_POLICY §6 チェックリスト**（8項目）を `- [x]` で自己確認。

## Dependency / Test Matrix（= acceptance proof）

| area | risk | proof |
|---|---|---|
| 必須リージョン | region 欠落 | 各 wireframe に context strip / work surface / primary action / empty が揃う |
| work surface first | 先頭がラベル/row | 各 normal box で主役が最初・最大 |
| empty=CTA | 状態ラベル列 | 各 empty box が行動ボタン |
| label budget | 内部語彙混入 | 主面に型説明/readiness/debug 語が無い |
| 2状態 | empty 欠落 | 全6タブに normal+empty |
| QA/Validate 除外 | 誤って作成 | wireframe に QA/Validate が無い |

## Planned steps

1. per-tab 仕様を ASCII 化（normal）。
2. 各タブ empty を ASCII 化。
3. §6 チェックリストを各タブに付す。

## Planned completion criteria（二層 DoD）

- S: 6タブ ASCII wireframe / resource 退避先・primary surface 明記 / §6 チェックリスト全項目。
- E: 各 wireframe で「最初に見えるもの」「primary action」がラベル説明なしで成立、normal+empty の2状態。
- test: code 非変更のため `./tools/test.sh` は回帰確認のみ（green）。
