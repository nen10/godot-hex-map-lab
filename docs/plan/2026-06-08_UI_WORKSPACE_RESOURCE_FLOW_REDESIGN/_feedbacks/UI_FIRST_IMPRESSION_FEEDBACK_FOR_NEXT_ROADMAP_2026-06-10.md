# Hex Map Kit UI First Impression Feedback for Next Roadmap 2026-06-10

作成日: 2026-06-10  
目的: `UI_WORKSPACE_RESOURCE_FLOW_REDESIGN` 実行後のユーザー実機確認・スクリーンショット指摘を、次回 roadmap 作成のための feedback として整理する。  
対象観点: first impression、UI情報密度、Resource選択UX、HexTileMap node / Resource同期、Generate / Paint / Catalog / Settings の画面理解、debug情報の扱い。

---

## 0. 総評

今回のUIは、内部設計としては前進している。Tab構造、Resources tab、sample分離、auto-link、Resource context、Generate progress など、前回のroadmapで狙った機能は見えている。

しかし、ユーザーが最初に触る画面としては、まだ **機能実装の存在を示すためのlabel / status / placeholder / debug情報が多すぎて、作業対象と次の操作が読めない** 状態に見える。

最も重要な認識はこれである。

```text
今の問題は「機能が足りない」だけではない。
実装済み機能を画面に出す時の情報設計が壊れている。
```

次のroadmapでは、単にボタンを直すのではなく、以下を上位方針にするべきである。

```text
1. 画面に常時出す情報を最小化する。
2. debug / filepath / internal state は常時label表示しない。
3. Resource row は Godot 標準 ResourcePicker を中心に、1行または狭幅2行へ統一する。
4. 各tabは ScrollContainer 下に実体controlを持つ。
5. Resource / Document / Viewport / HexTileMapLayer の状態遷移を明文化する。
6. no-opや意味不明なボタンは削除する。説明labelでごまかさない。
7. sample bundle は learning path に限定する。
8. visible UI は screen contract によって管理し、不可視に残った旧controlを増やさない。
```

---

## 1. 大局的な改善策の候補

### 案A: Minimal UI Repair

目的は、現在の構造を大きく壊さず、最も不快な初見問題を潰すこと。

対応:

- 全tabのrootを確実に `ScrollContainer -> MarginContainer -> VBoxContainer` にする。
- Resource rowを共通controlへ統一する。
- 長いlabel / filepath / node path を消す。
- `Details` / `OK` / `Missing` / `Optional` などの常時文字表示を icon + tooltip へ置換する。
- `Create New...` の個別ボタンを消し、bulk createへ寄せる。
- Generate / Paint の空白領域・不可視controlの原因を修正する。
- Settingsの `true/false` / `on/off` 文字labelを削除する。

利点:

- 早い。
- 既存実装を大きく動かさない。
- first impression が即改善する。

欠点:

- 根本的な screen responsibility の混在は残る。
- Catalog / Layers / Validate / QA / Export が本当の作業画面になるには別途作業が必要。

推奨度: **高。ただし短期修正として扱う。**

---

### 案B: Resource-Centric Workspace

`Resources` tab を中心に、選択中 `HexTileMapLayer` が使う Resource set を一括管理する設計へ寄せる。

画面構成:

```text
Resources
  Selected HexTileMap summary
  Required resources status
  Bulk Create Missing Resources
  Resource rows
  Copy Resource Debug Report

Generate / Paint / Catalog / Layers / Validate / QA / Export
  Resources tabで決まったcontextを使う
```

利点:

- Resource参照・作成・保存・auto-linkの混乱を一箇所で解消できる。
- 各tabがResource選択UIで埋まる問題を減らせる。
- `HexTileMapLayer` の作業contextが分かりやすい。

欠点:

- Resources tab が強くなりすぎると、各tabの独立性が下がる。
- Shared Resource / Unique Resource / Optional Resource の設計を明確にする必要がある。

推奨度: **高。現在の問題に最も合っている。**

---

### 案C: Task-Centric Workspace

各tabを完全に独立した作業画面として育てる。

```text
Generate: generation profile, preview, apply, progress
Paint: brush, layer, selected cell, edit mode
Catalog: catalog entries, tile preview, scene preview
Layers: role tree, visibility, apply policy
Validate: issue navigator, focus, fix suggestions
QA: seed table, score, promote
Export: output type, destination, runtime handoff
Settings: samples, debug, preferences
```

利点:

- ユーザーが「どこで何をするか」を理解しやすい。
- `Paint tabなのにResource一覧しかない` 状態を避けられる。
- 将来的に各screenを独立scriptへ分割しやすい。

欠点:

- 作業量が大きい。
- Resource context の共有モデルが先に必要。
- 途中段階では表示が崩れやすい。

推奨度: **中〜高。案Bの後に進めるのがよい。**

---

### 案D: State-Machine Driven UI

UIを「状態遷移モデル」から組み立てる。ユーザー指摘にあるとおり、実装済み機能と実際のUX体験に乖離が積み重なっている可能性があるため、画面状態を明文化する。

必要な状態例:

```text
No HexTileMap selected
HexTileMap selected, resources missing
Resources selected, not linked
Resources linked, document not saved
Generated preview exists
Preview applied to document, document dirty
Document saved, viewport out of date
Viewport rebuilt from document
Validation has issues
Export destination missing
Sample learning mode on
Debug display mode on
```

利点:

- 不可視controlやno-op buttonが増えにくい。
- テストがUI見た目ではなく状態契約を確認できる。
- Generate / Document / Viewport / Resource保存状態の混乱に強い。

欠点:

- 最初に設計文書が必要。
- UI実装の自由度は少し下がる。

推奨度: **高。次回roadmapに必ず入れるべき。**

---

### 推奨方針

短期は **案A + 案D**。  
中期は **案B + 案C**。

つまり次の順番がよい。

```text
1. UI screen contract / state machine / visible control inventory を作る
2. Resource row と debug表示policyを修正する
3. Resources tab を中心に HexTileMapLayer のResource contextを安定させる
4. Generate / Paint / Catalog / Layers / Validate / QA / Export を作業画面として再構築する
```

---

## 2. Tab共通 feedback

### 2.1 labelが途中で切れて読みにくい

スクリーンショットでは `Level D`、`Tile Ca`、`Movem` のようにResource名が途中で切れている。これはかなり悪い初見体験である。

問題:

- 何のResourceか分からない。
- 省略されたlabelの意味を推測させる。
- 右側には詳細やstatusが多く、ユーザーの視線が散る。

Generate tab の row に近い設計を参考にし、Resource row は次のどれかに統一する。

#### Row案1: Compact one-line row

```text
[status icon] [Resource title] [ResourcePicker........................] [optional primary action]
```

- `Resource title` は短く、切らない。
- どうしても狭い場合は ellipsis + tooltip。
- `ResourcePicker` は横幅を最大に取る。
- `Details` ボタンは置かない。

#### Row案2: Narrow adaptive two-line row

狭いdockでは1行に詰め込まない。

```text
[status icon] Level Document
[ResourcePicker........................................]
```

- これが最も安全。
- Godot dock は幅が変わるため、一定幅以下では2行化した方がよい。

#### Row案3: Resource table + selected detail drawer

```text
[✔] Level Document      [ResourcePicker]
[ ] Tile Catalog        [ResourcePicker]
[○] Object Database     [ResourcePicker]

▼ Selected Resource Details
```

- Resource一覧性は高い。
- 詳細は下部drawerかtooltipへ逃がせる。


推奨: **Row案2を基本にし、広い時だけRow案1へ寄せる。**

##### ユーザー意見

常に Row案1 でfixします。fittingのための設定はGenerate tab 内のrowを参考にします。

---

### 2.2 label情報が不快感を作っている

現在の画面には、ユーザーが興味を持つ前に、internal state、filepath、node path、status text、optional/missing分類などが出すぎている。

方針:

```text
画面上の常時label = 意味が理解できる情報 (i.e. label の右隣に関連する操作可能コントロールが存在する場合) のみ、許可する
それ以外のlabelは削除する。<必要な場合> 内部情報 / filepath / debug state : Copy Debug Report ボタンへ集約
```
label運用をdocumentationする。
各tabに置いてよいdebugボタンは最大1つ。別にdebugしたいことがなければ置く必要もない。コードが肥大化しているため、コード削減を検討して良い。

例:

```text
Resources tab / [Copy Resources Debug]
Generate tab / [Copy Generate Debug]
Paint tab / [Copy Paint Debug]
[Copy Workspace Debug]
```


禁止:

- node path の常時表示。
- filepath の常時表示。
- debug用の説明文をlabelとして並べる。
- true/false, on/off 文字列を状態表示としてlabel内で使用する

---

### 2.3 ScrollContainer policy

ユーザー指摘どおり、dock tab内に追加するcontrolは必ずscroll可能な親の下に置く。

必須構造:

```text
TabPage
  ScrollContainer
    MarginContainer
      VBoxContainer
        content...
```

Generate tab も例外にしない。スクリーンショットではGenerate tabの大部分が謎の空白または非active領域に見えるため、以下を確認する。

- inactive control が visible のまま高さだけ持っていないか。
- hidden container が `visible=false` でも minimum size を持っていないか。
- ScrollContainer の外に大きな Control を追加していないか。
- Tab切替時に旧controlが残っていないか。
- `size_flags_vertical` が不適切に `EXPAND_FILL` になっていないか。

---

## 3. Generate tab feedback

### 3.1 画面の8割近くを覆う謎領域

これは最優先で解消するべきである。

考えられる原因:

- 非active controlがvisibleのまま残っている。
- Generate用のpreview / progress / output panel が空のまま大きなminimum sizeを持っている。
- ScrollContainerの外側にcontrolが追加されている。
- 旧GenerateDockと新Workspace panelが二重にlayoutされている。
- `Preview only` / `Apply to Document` / progress area の状態切替が未整理。

必要なdocument:

```text
WORKSPACE_VISIBLE_CONTROL_INVENTORY.md
GENERATE_TAB_SCREEN_CONTRACT.md
WORKSPACE_STATE_MACHINE.md
```

`Generate` tab の各controlについて、以下を明記する。

```text
control id
owner screen
visible when
hidden when
minimum size
parent container
user purpose
test contract
```

---

### 3.2 Generate結果が何に反映されるか分からない

これは非常に重要。Generate は map全体を変える操作なので、結果の所有者が分からないと安心して使えない。

現状の混乱:

```text
Preview only とは何か
Apply to Document とは何か
Viewport Layer表示は何を見ているのか
Document Resourceは保存済みなのか
HexTileMapLayerに保持された状態はDocumentと同じなのか
Reloadとは何をreloadするのか
```

### 3.3 生成結果の所有モデル候補

#### 案A: Document is source of truth

```text
Generate Preview -> Apply to Level Document -> Rebuild View from Document -> Save Document
```

- `Level Document` が唯一の正規データ。
- Viewport / TileMapLayer は表示キャッシュ。
- Generate結果はまずpreview、apply後にdocument dirty。
- 保存はdocument resourceの保存。

利点:

- 最も理解しやすい。
- Save / Reload / Export の意味が整理できる。
- Runtime loadとも相性が良い。

欠点:

- previewとapplyのUI設計が必要。

推奨: **最有力。**

#### 案B: HexTileMapLayer is source of truth

```text
Generate -> HexTileMapLayer state -> optional export document
```

利点:

- viewport上では即時に見える。

欠点:

- Resource保存との関係が分かりにくい。
- scene保存とresource保存が混ざる。
- 現在のユーザー混乱を悪化させやすい。

推奨: **非推奨。**

#### 案C: Draft context model

```text
Generate Draft -> Preview Layer
             -> Apply to Document
             -> Discard Draft
```

利点:

- preview / compare / QA と相性がよい。
- 大きな生成結果をいきなりdocumentに書かずに済む。

欠点:

- Draft / Document / Viewport の3状態を明確に表示する必要がある。

推奨: **将来QA/Seed Labと組み合わせるなら有力。短期は案Aでよい。**

ユーザー意見: 複数の仮想的中間生成マップによる tilemap filtering generation pipeline の設計も進めます。そのため、C案の構造は長期的に干渉する可能性がある。C案は安易に採用しないでください。

### 3.4 Reloadボタンの考え方

ユーザー提案:

1. `HexTileMapLayer` の保存状態を viewport layer表示に反映する reload
2. `Document等Resource` の保存状態を viewport layer表示に反映する reload

この2つをUIに分けて出すのは、現時点では混乱が強い。

推奨:

```text
通常UIには 1つだけ出す:
[Rebuild View from Document]
```

意味:

- 現在のLevel DocumentからViewport/TileMapLayer表示を作り直す。
- HexTileMapLayerの表示キャッシュを更新する。

別途debug用にだけ持ってよい:

```text
[Reload Resource from Disk]
[Rebuild TileMapLayer cache]
```

ただし通常UIには出さない。必要なら `Copy Generate Debug` に状態を入れる。

ユーザー意見: 起動時の標準の動作・Generation時の標準の動作がどうなっているのかわからないので、Reloadボタン押下により動作比較することで、動的に現状仕様を確認できると考えて提案しただけです。わかりやすい開発設計提示をせっけいしてくれれば十分です。

### 3.5 Generate tabに必要なstatus

labelを増やさず、状態pillだけにする。

```text
Target: Level Document
State: Preview / Applied / Dirty / Saved / View out of date
Action: Apply Preview to Document / Rebuild View / Save Document
```

例:

```text
[Preview exists] [Apply to Document]
[Document dirty] [Save]
[View out of date] [Rebuild View]
```

#### ユーザー意見

いきなり何の話しをしているのかわかりません。Generate Tab 画面は旧来、ユーザーが丁寧に確認してlabel表示含めて整えてきた項目です。8割が表示されず、現状の状態を隠して指摘ができない隙に、なにか多くの変更を突然加えようとしないでください。提案済みの状態遷移管理対応などの合理的で明快な指針をもとに方針を十分整理してください。


---

## 4. Paint tab feedback

### 4.1 何も表示されていない

スクリーンショットでは Paint tab が空に見える。これは「機能が無い」より悪く、**機能が実装済みなのか、state条件で隠れているのか、layout不具合なのか判断できない**。

必要な方針:

```text
Paint tab は空にしない。
状態に応じたempty stateを必ず表示する。
```

例:

```text
No paint tool active.
Select a cell in the 2D viewport, or choose a brush below.

Active Document: Not selected
Active Layer: Not selected
Brush: Terrain / Object / Label / Zone
```
ユーザー意見:
ScrollContainerと配置するべきコントロールの親子関係等を確認しつつ、ネストを整理してみるのはどうでしょうか。

### 4.2 UI機能とUX体験の乖離

ユーザー指摘のとおり、改修のたびに不可視controlが残り、実装済みUI機能とUX体験に乖離が積み重なっている可能性がある。

対策:

- UI設計専用documentを作る。
- 各screenの visible control inventory を更新する。
- 状態遷移モデルを作る。
- UI task完了時に `visible controls` と `hidden controls` を記録する。
- `orphan visible/hidden controls` を検出するtestを入れる。

必要ドキュメント:

```text
docs/design/ui/WORKSPACE_SCREEN_CONTRACT.md
docs/design/ui/WORKSPACE_STATE_MACHINE.md
docs/design/ui/VISIBLE_CONTROL_INVENTORY.md
docs/design/ui/RESOURCE_ROW_SPEC.md
docs/design/ui/DEBUG_LABEL_POLICY.md
```

---

## 5. Resources tab feedback

### 5.1 個別の Create New は不要

ResourcePickerがResource作成を提供できるので、個別の `Create New...` ボタンは原則不要。Godot公式の `EditorResourcePicker` は、Editor Inspectorと同様にResource型プロパティを編集するControlであり、Resourceの作成・読み込み・保存・変換のoptionを提供するため、その標準挙動へ寄せるべきである。

必要なのは個別作成ではなく、以下。

```text
[Create Missing Required Resources]
```

対象:

- Level Document
- Layer Stack
- 各 local/default resources

動作:

```text
1. 保存先フォルダを選択
2. 必須Resourceを一括作成
3. HexTileMapLayerの参照を更新
4. Scene/nodeをdirtyにする
5. ユーザーの Command+S で保存できる状態にする
```

### 5.2 auto-link の意味が不明

現状の `Auto-link: On` は分かりにくい。

考えられる意味が複数ある。

#### 解釈A

```text
選択中 HexTileMapLayer が持つResourceを dock が自動で読む
```

#### 解釈B

```text
dockでResourceを選んだら、選択中 HexTileMapLayer に自動で設定する
```

#### 解釈C

```text
ResourcePicker左のlink/embedding状態と同期する
```

これらが混ざっているため混乱する。

推奨する用語:

```text
Follow Selected HexTileMap: On
```

意味:

- scene selection に追従する。
- 選択中 `HexTileMapLayer` のResourceをWorkspaceに読み込む。
- WorkspaceでResourceを変更したら、選択中 `HexTileMapLayer` に反映する。

画面表示:

```text
this dock Following: HexMapLayer2
```

または

```text
Target: HexMapLayer2  [following]
```

`Auto-link` という言葉は廃止候補。

ユーザー意見:
"解釈B : dockでResourceを選んだら、選択中 HexTileMapLayer に自動で設定する" の機能追加も可能なら進めます。こちらに関しては操作すればわかることであり、label説明表示不要です。




### 5.3 ResourcePicker左のcube形状マーク

これはGodotのResource選択UIに由来する標準的なResource icon / type indicator と見るのが自然である。`EditorResourcePicker` はInspectorのResourceプロパティ編集と同様の挙動を再現するControlであり、作成・読み込み・保存・変換などの操作optionを提供する。

提案:

- cube icon は Godot標準ResourcePickerの一部として残す。
- ただし、それとは別に独自のlink/embedding iconを左側に追加しない。
- ResourcePickerの標準menuでできることは、独自buttonで重複しない。
- link状態は別の小さいstatus badgeで表す。

ユーザー意見:
cube icon を押しても何も起こらないので、扱いの今後の方針を整理してください。

### 5.4 status表示

`OK / Missing / Optional` の文字列は邪魔になりやすい。

推奨:

```text
Required selected: ✔︎
Required missing: ❌
Optional selected: ✔︎ or subtle filled check
Optional missing: ◌ or gray hollow check
Warning: ⚠︎
Sample source: 🎓 or Sample badge only in debug/details
```

Godot editor theme iconを使える場合は、`get_theme_icon()` / theme icon lookup を使う。正確なicon名はGodot version/themeに依存するため、候補iconを調査し、存在しない場合はunicode/text fallbackでよい。

### 5.5 Details button

`Details` ボタンは不要。ただし tooltip の内容は有用。

移行先:

- Resource title label の tooltip
- status icon の tooltip

tooltipに入れる情報:

```text
Resource purpose
Unique / Shared / Optional / Sample
Required when
Current source: Node / Document / Manual / Sample
Saved path
Validation summary
```

通常画面に出さない。

---

## 6. Catalog tab feedback

### 6.1 状態表示が一貫していない

ユーザー指摘:

```text
CatalogのResourceを作成・参照・linkしても、No tile catalog selected と表示される
```

これは状態遷移管理のバグ、または表示参照元の不一致である。

原因候補:

- ResourcePickerの選択状態と Workspace context が同期していない。
- Catalog tab が別のsourceを見ている。
- HexTileMapLayer / Document dependencies / Manual selection のsource優先順位が曖昧。
- link/auto-link状態の意味が曖昧。
- Resource rowは更新されたが Catalog summary panel が古いstateを見ている。

対策:

```text
Catalog tab should read exactly one source of truth:
WorkspaceAssetContext.tile_catalog
```

そしてsource badgeを持つ。

```text
Tile Catalog: selected
Source: Selected HexTileMap / Document dependency / Manual / Sample
```

`No tile catalog selected` は、本当に `WorkspaceAssetContext.tile_catalog == null` の場合だけ出す。

---

## 7. Settings tab feedback

### 7.1 true/false, on/off labelを消す

チェックボックスは、それ自体が状態表示である。

悪い例:

```text
Show samples: On
[checkbox] Show samples
```

良い例:

```text
[ ] Show bundled samples in asset pickers
```

状態textは不要。

### 7.2 debug labelをコピー用ボタンに集約

Settings tabにもdebug情報を常時表示しない。

```text
[Copy Settings Debug]
```

コピー内容:

```text
sample mode flags
follow selected HexTileMap flag
debug UI flag
selected resources source
workspace state
```

### 7.3 Settings tab の構成案

```text
Settings
  Samples
    [ ] Show bundled samples in asset pickers
    [ ] Use samples for scratch documents
    [Duplicate sample catalog to project]

  Workspace
    [x] Follow selected HexTileMap
    [ ] Show debug details

  Debug
    [Copy Workspace Debug]
```

`true/false` ラベルや内部状態テキストは不要。

---

## 8. Debug表示方針

### 8.1 通常表示に出してよい情報

```text
Selected target name
Missing required resources count
Current mode
Dirty/saved state
Preview/applied state
Validation issue count
```

### 8.2 通常表示から消す情報

```text
full node path
full resource path
resource source internals
boolean state labels
class names repeated as labels
operation logs
fallback/debug flags
```

### 8.3 Debug copy button

各tab最大1つ。

```text
Resources: [Copy Resource Debug]
Generate: [Copy Generate Debug]
Paint: [Copy Paint Debug]
Catalog: [Copy Catalog Debug]
Settings: [Copy Settings Debug]
```

またはWorkspace共通で1つでもよい。

```text
[Copy Workspace Debug Report]
```

推奨: **Workspace共通1つ + tab-specific payload included by current tab**。

ユーザー意見: debug mode : true時のみボタン表示

---

## 9. UI設計専用document整備

今回のユーザー指摘は、UI設計文書が足りないことを示している。

追加すべきdoc:

### 9.1 `WORKSPACE_SCREEN_CONTRACT.md`

各tabについて記載。

```text
tab name
purpose
primary user action
required visible controls
empty state
active state
hidden controls
resource dependencies
debug copy payload
```

### 9.2 `WORKSPACE_STATE_MACHINE.md`

状態遷移を記載。

```text
No target
Target selected
Missing resources
Resources ready
Preview generated
Document dirty
Viewport out of date
Validation issue exists
Sample mode on
Debug mode on
```

### 9.3 `VISIBLE_CONTROL_INVENTORY.md`

毎UI改修後に更新。

```text
control id
parent tab
visible condition
hidden condition
owner task
is user-facing
is debug-facing
```

### 9.4 `RESOURCE_ROW_SPEC.md`

Resource rowの設計を固定。

```text
layout
status icon
resource picker behavior
tooltip policy
forbidden buttons
narrow dock behavior
```

### 9.5 `DEBUG_LABEL_POLICY.md`

labelとdebug copyの線引き。

```text
what may be visible
what must go to clipboard
per-tab debug button limit
```

---

## 10. Roadmap候補task

### `UI-DOC-00_CREATE_WORKSPACE_UI_CONTRACTS`

目的:

- UI設計専用documentを作る。

成果物:

```text
WORKSPACE_SCREEN_CONTRACT.md
WORKSPACE_STATE_MACHINE.md
VISIBLE_CONTROL_INVENTORY.md
RESOURCE_ROW_SPEC.md
DEBUG_LABEL_POLICY.md
```

Acceptance:

- 各tabのpurposeとvisible controlsが定義される。
- Paint tab が空になる条件が定義されない、またはempty stateが定義される。
- no-op buttonは禁止される。

---

### `LAYOUT-00_SCROLL_AND_EMPTY_AREA_REPAIR`

目的:

- Generate / Paint の謎空白と非scroll領域を修正する。

Acceptance:

- Generate tab, Paint tab の全contentがScrollContainer配下。
- Paint tab が空表示にならず empty state またはcontrolsを表示する。親子関係・ネスト等とsizingをチェック。
- hidden/inactive control がlayout領域を占有しない。

---

### `RESOURCE-00_RESOURCE_ROW_REDESIGN`

目的:

- Resource tab と各tabのResource参照UIを全面的に簡略化する。

Acceptance:

- label切れがない。
- `Details` button 削除。
- `OK/Missing/Optional` text を status icon へ置換。
- tooltipがResource title/status iconに移る。
- `Clear / Select / Open / Validate` の冗長ボタン削除。
- 個別 `Create New...` 削除。
- bulk create required resources は残す。

---

### `RESOURCE-01_FOLLOW_SELECTED_HEX_TILE_MAP_RENAME_AND_SEMANTICS`

目的:

- `Auto-link` 概念を明確化する。

Acceptance:

- `Auto-link` という表示を廃止または `This dock follow selected HexTileMap` に変更。
- selected node -> workspace context の読み込み。
- workspace resource change -> selected node の更新。
- link/embedding iconの意味を整理。
- Resource選択するがlinkしないユースケースがなければ手動link UIを消す。自動link化

---

### `RESOURCE-02_BULK_CREATE_REQUIRED_RESOURCES`

目的:

- 個別Createではなく、不足必須Resourceを一括作成する。

Acceptance:

- save directory選択。
- 必須Resource生成。
- HexTileMapLayer参照更新。
- scene dirty化。
- Command+Sで保存可能。

ユーザー意見:
もしかしてあらゆる操作について統一的なUndo/Redo操作を保証する必要がありますか？

---

### `CATALOG-00_CATALOG_STATE_SOURCE_OF_TRUTH`

目的:

- Catalog tab の `No tile catalog selected` 不一致を解消する。

Acceptance:

- Catalog tab は `WorkspaceAssetContext.tile_catalog` だけを見る。
- Resource row / Catalog summary / Validate state が同じsourceを見る。
- source badgeがある。

---

### `SETTINGS-00_SETTINGS_LABEL_SIMPLIFICATION`

目的:

- Settings tab から true/false label とdebug labelを消す。

Acceptance:

- チェックボックスだけで状態が分かる。
- debug情報は `Copy Settings Debug` に集約。
- sample settings の文言をlearning pathとして整理。

---

### `GENERATE-00_DOCUMENT_PREVIEW_APPLY_SAVE_MODEL`

目的:

- Generate結果がDocument/Viewport/Resourceにどう反映されるかを明文化し、UIに反映する。

Acceptance:

- Preview / Apply / Save / Rebuild View の状態が明確。
- Generate結果の所有者が画面から分かる。
- reloadボタンは通常UIでは1つに絞る。
- debug reloadはdebug copy/reportへ退避。

---

### `PAINT-00_PAINT_TAB_EMPTY_STATE_AND_BRUSH_SURFACE`

目的:

- Paint tabが空に見える問題を解消する。

Acceptance:

- Paint tabには常に empty state または active brush panel がある。
- 2D viewport編集とPaint tabの関係が分かる。
- Paint tabに非Paint責務を積まない。

---

## 11. 推奨実行順

```text
1. UI-DOC-00_CREATE_WORKSPACE_UI_CONTRACTS
2. LAYOUT-00_SCROLL_AND_EMPTY_AREA_REPAIR
3. RESOURCE-00_RESOURCE_ROW_REDESIGN
4. RESOURCE-01_FOLLOW_SELECTED_HEX_TILE_MAP_RENAME_AND_SEMANTICS
5. RESOURCE-02_BULK_CREATE_REQUIRED_RESOURCES
6. CATALOG-00_CATALOG_STATE_SOURCE_OF_TRUTH
7. SETTINGS-00_SETTINGS_LABEL_SIMPLIFICATION
8. GENERATE-00_DOCUMENT_PREVIEW_APPLY_SAVE_MODEL
9. PAINT-00_PAINT_TAB_EMPTY_STATE_AND_BRUSH_SURFACE
```

---

## 12. 最終結論

今回の指摘は、具体的である。

現状のUIは、機能の内部実装が進んでいる一方で、画面上では以下が混ざっている。

```text
- ユーザーが今やるべき操作
- internal state
- debug path
- Resource class name
- sample learning path
- missing/optional status
- old control placement
- no-op or unclear buttons
```

根本的な設計について改善を進めたのち、本件のUX設計と細かな具体的修正を進める。


```text
Level Document / Resource / HexTileMapLayer / Viewport の関係を、
Generate と Paint のUI上で明確にする。
```

これが明確になれば、Reload、Apply、Save、Auto-link、Resource作成、Catalog選択、Paint編集のすべてが説明しやすくなる。
