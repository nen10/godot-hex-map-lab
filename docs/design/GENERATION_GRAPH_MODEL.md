# Hex Map Kit — Generation Graph Model (MVP 設計)

確定日: 2026-06-15
ステータス: baseline（製品本体＝§3 背骨の具体化。次期 Roadmap `GRAPH-40/41/42/43` の参照元）
関連: `docs/design/PRODUCT_DEFINITION.md`（§3 背骨）

---

## 0. 位置づけ

これは製品定義 §3「複数生成方式 layer を pipeline 合成し、形状を越えて一貫基準で terrain/object を配置する node graph editor」の具体設計。**graph が製品の本体**。

実査の結論：**必要な生成エンジンはほぼ全て既存**。graph が新規に作るのは orchestration 層（Node/Port/Edge/Run/Promote）と Build tab の canvas のみ。

---

## 1. 設計原則（最重要）

1. **Headless / Resource参照 / UI非依存な pass**
   各ノードの生成ロジックは、core の static 関数を呼ぶ **headless pass**（`run(inputs, params, context) -> output`）として実装し、catalog/profile/document 等は **Resource ハンドルで参照**して run 時に解決する。**graph canvas はノード/param/edge の authoring のみ**を担い、生成ロジックを所有しない。
   - これは既存 filter/overlay 生成の debt（UI(`hex_map_gen_dock.gd` 5961行)に生成方式が結合し、Resource を参照しにくく headless 再利用ができない）の根本是正。
2. **プリミティブは再利用、再実装しない**（§9 参照）。
3. **shape 非依存 → graph 自体が「一貫基準」**。プリミティブは cell 集合に対して動くため、同一 graph を別 shape/seed に適用しても一貫配置が得られる。これが製品の頭出し価値。

---

## 2. Port 型（4種、すべて実型に対応）

| port型 | 中身 | 実型 |
|---|---|---|
| `terrain` | cells + walls（地形substrate） | `HexMapData` |
| `selection` | cell集合 / mask（中間フィルター座標） | `Array[HexPoint]` / set（`query_item_cells` 出力） |
| `overlay` | item_key → cells（item/object配置層） | `HexOverlayData` |
| `result` | 梱包結果（preview/score/promote/replay） | `HexGenerationResultResource` |

**G1 決定**: 中間 port は `overlay` 1本に統合。terrain / overlay / object の区別は **Promote の target role でのみ**行う。

---

## 3. Node 型（MVP、各ノード＝既存関数1呼び出し）

| Node | in → out | 実装（core static） |
|---|---|---|
| **Source / Layer Input**（G1 新規） | （既存層）→ `terrain` / `overlay` | Document terrain/overlay/objects・既存マップ placement・prior result を graph へ取り込む |
| **Shape** | params → `terrain` | `generate_rectangle/hexagon/toric_square` |
| **Wall Field**（Markov Mesh） | `terrain` + seed + wall_prob → `terrain` | `generate_random_walls` / `generate_symmetric_toric_walls` |
| **Connectivity**（通路fallback） | `terrain` (+terminals:`selection`) → `terrain` | `restore_connectivity*` / `restore_terminal_connectivity` |
| **Region Filter** | `terrain`/`overlay` → `selection` | `query_item_cells(AND/OR)` / `item_cells(Floor/Wall)` / adjacency |
| **Item Generator** | `selection` + weighted pool + seed → `overlay` | `generate_random_items` / `generate_limited_items` / `generate_toric_adjacency_items` |
| **Compose** | 2+ `overlay`/`terrain` → `overlay`/`terrain` | `apply_overlay(write_policy, existing_policy)` |
| **Promote** | `terrain`/`overlay` + target role → Document層書き込み | document adapter |
| Validate（park ※中心化しない） | `terrain`/document → `result` | `validate_document`（任意のPoCレンズ） |

---

## 4. 既存レイヤーを filter 入力にする（G1）

**Source ノード**により、新規生成だけでなく **primary 生成結果・既存 Document のタイル配置・既存マップの placement** を `terrain`/`overlay` として graph に取り込み、Region Filter の入力にできる。

```
[Source: 既存Document overlay] ─overlay→ [Region Filter: item=="door"] ─selection→ [Item Generator ...]
```

これにより「すでに置いてあるタイル/オブジェクトを基準に次の配置を決める」が自然に成立する。

---

## 5. Run UX（G2）

- **頭出し（primary action）= Generate（N=1）**。最初の体験は「param を変えて Generate、結果を見る」。
- **降格配置（下方）**: 生成枚数 `N`（数値入力, **default 1**）/ seed randomize / shape randomize。`N>1` + randomize で「一貫基準の束」を得る——**半オプション**（初手の体験にしない）。
- 理由: 生成は重い。最初から N 枚生成は初手候補にしない。
- **Run model**: DAG をトポロジ順に実行、中間 output を cache、上流変更で dirty 伝播。

---

## 6. Promote

ノード output（`terrain`/`overlay`）を、**target role**（terrain / overlay / object）を指定して `HexMapDocumentResource` の対応層へ書き込む。「本当に使うレイヤー」の出力点。

---

## 7. Graph resource のライフサイクル（保存・出荷・runtime build・再読込）

- **保存形態（G3）**: MVP は内部 Dictionary 駆動。公開 API 化の前に `HexGenerationGraphResource`（Node/Port/Edge）へ Resource 化。次期 `GRAPH-41` と整合。
- **双方向**: graph は (1) editor で著作 / (2) **出荷可能な runtime 生成資産** / (3) editor へ再読込して編集、の3用途を持つ。
- **runtime Map Build API**: 保存した graph resource を実行時に読み込み map を build（完全ランダム生成ユースケース）。製品定義 §0 の runtime 境界を「graph からの実行時生成」まで拡張（依然 map 生成であり gameplay ではない）。
- **embed vs reference**: graph が map semantics を *embed(スナップショット)* するか *reference(path)* するかは、runtime 自己完結性 ⇔ editor 整合のトレードオフ。→ §10 の load モードに対応。

---

## 8. 長期検討（perf）

生成・削減アルゴリズムの **C++ 移植（GDExtension）** は、生成の重さに対する長期候補。配布製品として体験速度に効く。MVP では採用しない。

---

## 9. 新規 vs 再利用

- **再利用（作らない）**: 生成（shape/wall/connectivity/item）・選択（`query_item_cells`）・合成（`apply_overlay`）・result 梱包・replay。
- **新規（これだけ）**:
  1. Graph model: `Node`(type, params, resource refs) / `Port`(型) / `Edge`(out→in) / 型検証
  2. Headless pass 層: 各 node type の `run(inputs, params, context)`（core static を呼ぶ、UI非依存）
  3. Run engine: DAG topo 実行 + 中間 cache + dirty 伝播
  4. Promote: node output → Document 層（role 指定）
  5. Build tab graph canvas UI（GraphEdit 採否は別途 `GRAPH-40`）

---

## 10. Editor 読込と文脈所有（O2-UX）

graph load 時の dock 文脈所有は、**独立した文脈所有システムを作らず**、既存の「選択中 node の resource 追跡」を再利用して実現する（O2-UX の最小コスト実装）。

- **default: 新規 HexTileMapLayer 生成**。graph を新 node の resource として復元 → その node が選択され、以降は既存追跡がそのまま適用。semantics は **embed（複製）** で自己完結（runtime build とも一貫）。
- **opt-in: 既存 HexTileMapLayer へ overwrite**（選択中が HexTileMapLayer の時のみ、checkbox **default off**）。semantics は **reference / merge**。
- **overwrite の安全弁**: `writable source` 準拠で **`generated` 層のみ置換**し、`document` / 手動(Paint)層は保持（Build/Paint 共存機構の再利用）。
- 効果: 文脈所有者は常に node 1つ＝**二重所有が発生しない**。新設は「graph→node 具現化(factory)」と load 入口のみ。既存 `hex_map_workspace_asset_resource_factory.gd` / `hex_map_sample_asset_duplicator.gd` を再利用。
