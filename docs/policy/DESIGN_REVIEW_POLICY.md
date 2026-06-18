# Design Review Policy

対象: Hex Map Kit の Roadmap、Implementation Queue、Task Packet、設計文書、UI / API contract、test / proof plan、実装後成果物
目的: 実装前または実装後の設計レビューで、Hex Map Kit の product / domain 判断が implementation slice へ正しく落ちているかを確認する。

origin: `godot-event-queue-manager/docs/devflow/policy/DESIGN_REVIEW_POLICY.md` を Hex Map Kit の Godot addon 開発向けに翻案した。

---

## 0. 結論

設計レビューは approval 待ちの儀式ではなく、実装が小さく縮小されすぎたり、逆に完了条件が曖昧な大 task になったりすることを防ぐ gate である。

Hex Map Kit では、特に次を分離して確認する。

- code が書けたこと。
- `./tools/test.sh` または対象 test で壊れていないこと。
- Core / Resource / Adapter / UI / docs / package の product proof が揃っていること。
- 旧 UX、暫定 schema、暫定 test、sample-only path を守るべき canonical contract と誤認していないこと。

設計レビューは、`docs/policy/DOMAIN_POLICY.md` と `docs/design/PRODUCT_DEFINITION.md` を上位判断として使う。Generation Graph を扱う場合は `docs/design/GENERATION_GRAPH_MODEL.md` も baseline とする。古い実装や古い test が accepted direction と矛盾する場合は、互換維持ではなく queue / task packet で置換方針を明示する。

## 1. レビューの目的

設計レビューでは次を確認する。

- 目的、入力資料、対象 workflow が明確である。
- 採用、棄却、延期する UX / API / policy 判断が明示されている。
- 実装対象が product slice として小さく分割され、各単位に完了条件がある。
- code test と product proof が分離されている。
- Core、Resource / API、Adapter、Workspace UI、Generation Graph、Runtime / Handoff、Docs / Demos / Package の依存が混ざっていない。
- 実装時に固定する contract と、addon 利用者または開発者が設定で変える control surface が分かれている。
- 追加要件が発生したときに、既存 task へ曖昧に混ぜず、Queue、Task Packet、contract 文書、optional prerequisite のどれかとして追跡できる。
- 既存の schema、UI path、golden、test fixture を変える場合は、使用実績を確認し、置換するのか互換性を維持するのかを設計側で明示している。

## 2. レビュー対象の分類

レビュー対象は、まず次のどれに当たるかを分類する。複数にまたがる場合は、失敗時の影響が最も大きい分類を主分類にする。

| 分類 | 対象例 | 見落としやすい問題 |
|---|---|---|
| roadmap / direction | `ROADMAP.md`、phase 設計、feedback 反映、product definition 反映 | workflow 価値ではなくファイル分割だけで phase 化する |
| queue / orchestration | `IMPLEMENTATION_QUEUE.md`、dependencies、proof log、phase review | 1 task が大きすぎる、または code fragment になり product value がない |
| task packet | `SUB_TASKS.md`、`UX.md`、`POLICY.md`、`IMPLEMENTATION_PLAN.md` | 採用 / 棄却判断、fallback、state invariant、test path が後段へ先送りされる |
| core map / generation | Hex 座標、map data、query、generation primitive、overlay apply | UI 都合で core contract を歪める、生成 primitive を不要に再実装する |
| resource / API contract | `HexMapDocumentResource`、Catalog、Layer Stack、profiles、graph resource、validation、public method | sample-only default、path string 主体、unknown field、round-trip、layer 境界が未確認になる |
| adapter / runtime boundary | `HexTileMapLayer`、document adapter、TileMapLayer bridge、runtime Map Build API、save / load | editor state や Node 参照が Resource / saved data に漏れる |
| generation graph / Build | node / port / edge、headless pass、run cache、dirty propagation、Promote | graph canvas が生成ロジックを所有する、中間 output から次 node へ繋がらない |
| editor UI / UX | Build、Paint、Resources、Layers、Catalog、Export / Handoff、Settings、workspace first impression | projection-first でない、label-heavy、sample が production source になる、no-op / hack path が残る |
| asset selection / sample | project asset selection、unconfigured state、sample duplication、learning path | sample preset success を production completion proof にする |
| QA / Validate / metrics | validation screen、QA panel、UI metric、static audit、layout snapshots | park 対象を主導線や product goal に中心化する |
| test / proof | `./tools/test.sh`、unit / headless / UI metric、golden、property test | test が旧 UX / API を温存する、golden diff を根拠なしに更新する |
| docs / demos / package | manual、demo scene、sample、addon manifest、dist / package | 実装前の manual が正本化する、demo が trace proof を持たない |
| generated artifact | golden、layout snapshot、metric report、generated docs、package artifact | 正本上書き、snapshot 保存、再生成条件が実装時に曖昧になる |
| provisional contract redesign | 暫定 schema、fixture、UI state、test oracle、generated artifact | ほぼ未使用の暫定形式を後方互換対象として守ってしまう |

## 3. 基本レビュー項目

以下は自明な項目として、設計ごとに見出しまたは表の列があればよい。

### 入力資料と根拠

参照した Roadmap、feedback、product definition、domain policy、既存実装、test、manual、review を path で書く。

### 目標と分割した目標

対象 workflow と、今回 task が担う product slice を明示する。大きすぎる場合は `SUB_TASKS.md` または queue へ分割する。

### 採用 / 棄却 / 延期判断

採用する UX / API / policy と、棄却または延期する選択肢を明示する。旧 UI や旧 test を残す / 削除する理由を書く。

### 実装範囲

Core、Resource / API、Adapter、UI、Docs、Tests、Package のどこまでを今回含むかを書く。含めないものは backlog、optional prerequisite、または明示的な reject にする。

### 成果物

code、test、golden、contract 文書、manual、demo、package artifact を分けて書く。

### 依存関係

先に必要な schema、state model、fixture、Godot runtime、editor surface、sample asset、contract 文書を Queue ID または path で追跡する。

### 実行順序

実装順、proof 生成順、docs 更新順を分ける。manual と package refresh は、説明対象の UI / API が安定してから行う。

### Test Gate

標準検証は `./tools/test.sh`。対象 slice に必要な unit / headless / UI metric / golden / manual / package 検査も書く。UI-facing task は UI metric report path と P0 failures = 0 を self-review に記録する。

### Product Proof Gate

code test とは別に、addon の価値が証明された状態を書く。例: project asset selection が通常導線になる、unconfigured / validation state が見える、graph の中間 output が次 node へ渡り Promote できる、runtime handoff が clean に読み込める。

### Compatibility / Replace Stance

既存 schema、fixture、UI path、test oracle を守るのか置換するのかを書く。未公開 addon の既定は `replace` だが、`active_canonical` の場合だけ migration / deprecation を検討する。

## 4. 要件整理レビュー

要件整理レビューは、1 task の実装規模を小さく保ちながら、必要な要件を漏らさず積み上げるために行う。追加要件は既存 task の説明へ曖昧に混ぜず、Queue、Task Packet、contract 文書、control surface、optional prerequisite のどれかとして追跡する。

| レビュー項目 | 確認すること | 設計へ残す内容 |
|---|---|---|
| code 完了と product 完了を分ける | 実装が通っただけで addon workflow が達成済みに見えないか | `test gate` と `product proof gate` を別に書く |
| 実装前に足りない前提を洗い出す | schema、fixture、Godot runtime、editor surface、sample asset、contract 文書が未準備ではないか | dependency map、prerequisite、Queue ID を書く |
| 前提ごとに解決計画を作る | 大きな前提を1行の注意書きで済ませていないか | 入力、出力、検証方法、実装順を書く |
| 依存を Queue 番号で追えるようにする | 「先にこれが必要」が文章だけになっていないか | task ID や scheduled task ID を依存列に明記する |
| 既存 Queue を壊さず追加 Queue を足す | 参照済み番号を renumber していないか | 新規 Queue ID、実行位置、dependency、acceptance を書く |
| 実装で固定する点を決める | 実装者の裁量で schema、Resource API、graph port、fallback、validation が変わる箇所が残っていないか | canonical schema、public method、port type、write policy、validation、fallback stance を固定する |
| 設定で変える入口を決める | addon 利用者や開発者が変えたい値が code 改変前提になっていないか | Resource、inspector option、graph param、Settings、dev-only toggle へ出す |
| 任意拡張を分ける | 今すぐ必須ではない genre policy、demo、adapter、visual polish が混ざっていないか | optional prerequisite または backlog として分離する |
| 暫定 contract を本採用 contract へ統一する | ほぼ未使用の schema、fixture、UI state、test oracle に互換層を増やしていないか | 使用実績、暫定判定、本採用形式、旧形式の破棄 / 再生成方針を書く |
| 成果物の種類を分ける | code、test fixture、golden、docs、package が同じ完了条件になっていないか | proof grade と artifact checkpoint を分ける |
| 長い検証を checkpoint 化する | Godot import、demo trace、UI metric、package check を1つの曖昧な完了条件にしていないか | smoke、targeted、full、再実行条件、出力 path を書く |
| 生成手順と設定を残す | golden や generated docs が再生成不能になっていないか | command、input、output、run-id、update 条件を self-review に残す |

## 5. 設計理念

以下は、対象分類に該当する場合に設計が満たすべき理念である。該当しない分類は省略してよい。

### map semantics は意味の源泉である

Catalog、Layers、Resources が cell の意味を決める。Build と Paint は同じ Level Document へ書き込むが、語彙、構造、束縛の責務を混ぜない。

対象分類: resource / API contract、generation graph / Build、editor UI / UX、docs / demos / package。

### UI は state の投影であり、state の源泉ではない

画面に出るものは headless state、selected project asset、Resource、Document から導出できる。UI 固有の状態が core / resource / simulation に逆流しない。

対象分類: editor UI / UX、task packet、test / proof、generation graph / Build。

### Resource / API は保存、復元、runtime 境界を越えて意味を保つ

canonical schema が存在し、保存・復元・layer 間転送・runtime handoff で意味が変わらない。上位層の都合が下位層の surface に漏れない。

対象分類: resource / API contract、adapter / runtime boundary、docs / demos / package、provisional contract redesign。

### Generation Graph は headless orchestration である

graph canvas は node / param / edge の authoring を担い、生成ロジックは headless pass が所有する。中間 output を次 node へ渡せず Promote だけが通る状態は graph completion ではない。

対象分類: generation graph / Build、core map / generation、adapter / runtime boundary、test / proof。

### 生成 state と手編集 state は境界を持つ

generated layer と authored / document layer の write policy を明示する。再生成が手作業を潰さない境界を設計し、UI 操作の都合で document truth を曖昧にしない。

対象分類: generation graph / Build、editor UI / UX、resource / API contract、test / proof。

### sample は learning asset であり production source ではない

sample preset success は production feature completion ではない。production feature は任意 project asset selection、user-selected Resource、または visible unconfigured / validation state を持つ。

対象分類: asset selection / sample、editor UI / UX、test / proof、docs / demos / package。

### テストは採用した契約を証明し、廃止した契約を温存しない

テストが守る対象は現在の accepted contract である。旧 UI、path text、raw JSON、numeric fallback、sample-only path を延命するための test は追加しない。検証不能な環境では完了扱いにせず阻害を記録する。

対象分類: test / proof、core map / generation、editor UI / UX、docs / demos / package。

### 文書は採用済み事実を説明し、demo は検証可能な証拠を持つ

manual は仕様を決める文書ではなく、決まった仕様を説明する文書である。demo と sample は学習素材であり、production の入力源にならない。生成物には再現手順が残る。

対象分類: docs / demos / package、generated artifact、test / proof。

### QA / Validate は park であり、主導線ではない

QA / Validate / metrics は製品価値の中心ではない。自律的に存続・改修してよいが、Build -> Paint -> Export / Handoff の主導線を置き換えない。

対象分類: QA / Validate / metrics、roadmap / direction、queue / orchestration、editor UI / UX。

### 未確立の契約は互換対象ではなく、置換対象である

ほぼ使われていない暫定形式を後方互換の対象として守らない。使用実績（`provisional_unused` / `limited_internal` / `active_canonical`）を分類し、互換性維持を検討するのは `active_canonical` の場合だけである。

対象分類: provisional contract redesign、resource / API contract、test / proof、docs / demos / package。

## 6. レビュー結果の記録形式

設計レビュー結果には、最低限次を残す。

| 項目 | 記録内容 |
|---|---|
| 対象 | Roadmap、Queue、Task Packet、設計文書、実装後成果物の path |
| 主分類 | レビュー対象の分類 |
| 判断 | `pass`、`pass_with_followups`、`needs_design_update`、`blocked` |
| 採用判断 | 採用する UX / API / policy / test proof |
| 棄却 / 延期判断 | 残さない旧 UX、暫定 contract、backlog へ送る optional scope |
| 実装固定点 | schema、API、graph port、adapter boundary、validation、fallback stance |
| control surface | Resource、inspector option、graph param、Settings、dev-only toggle |
| test gate | code 実装として通す検査 |
| product proof gate | asset selection、UI first impression、graph chain、runtime handoff、demo、package など product value の証明 |
| proof grade | `schema_only`、`headless_smoke`、`contract_tested`、`graph_run_proven`、`editor_projection_verified`、`asset_selection_verified`、`package_or_demo_verified` |
| 追加要件 | 新規 Queue、Scheduled task、contract 文書、optional prerequisite |
| provisional contract | 使用実績分類、本採用 contract、旧 contract の扱い、互換性判断 |
| 未解決リスク | 実装時に縮小されやすい点、Godot 環境依存、長時間検証、外部 asset 依存 |

記録先は対象に応じて選ぶ。

- Roadmap / phase: `docs/review/roadmap/`
- task plan review: `docs/review/plan/`
- autopilot execution review: `docs/review/autopilot/`
- UI / domain inventory: 対象 roadmap 配下、または `docs/review/ui/`

## 7. 完了条件

設計レビューは、次を満たしたときに完了とする。

- 目標、入力、成果物、依存、実行順序が書かれている。
- 採用、棄却、延期する UX / API / policy が明示されている。
- test gate と product proof gate が分離されている。
- 実装固定点と control surface が分離されている。
- 追加要件が Queue、Task Packet、contract 文書、control surface、optional prerequisite のいずれかに整理されている。
- 詳細レビュー項目のうち、該当分類に必要なものが確認されている。
- proof grade と、code 完了、artifact 完了、product review の境界が分かる。
- 暫定 contract を変える場合、互換性維持ではなく本採用 contract へ統一する意図、旧 contract の扱い、ユーザー確認事項が書かれている。
- UI / graph task の場合、structural DoD と experiential DoD が分離され、UI first impression または graph chain proof がある。
- sample-only success を production completion proof にしていない。
- Godot や標準検証環境がない場合、完了扱いにせず `BLOCKED_BY_TEST_ENV` と command / error を記録する。
