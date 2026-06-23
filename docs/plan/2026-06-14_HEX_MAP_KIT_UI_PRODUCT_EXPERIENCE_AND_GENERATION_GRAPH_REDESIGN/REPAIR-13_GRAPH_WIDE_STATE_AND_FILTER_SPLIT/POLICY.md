# REPAIR-13 Policy

## 基本方針

Build graphは動的graphであり、固定画面の単純な状態遷移表では管理しない。

管理対象は以下に分ける。

- graph構造から毎回導出できるstate。
- 実行中だけ保持するrun state。
- viewport previewに関するpreview state。
- editor選択layer/documentに関するcontext state。

## 禁止する設計

- graph全体を巨大なFSMとして全組み合わせ列挙する。
- UIに表示された値だけで「runnerに伝達された」とみなす。
- graph cacheの存在だけでGenerate成功とみなす。
- `Apply`をviewport projectionの発生源にする。
- `Source`を型不明のまま、Terrain/Overlay Filter分離後も放置する。
- `Region Filter`の既存挙動を仕様として固定する。

## 必須にする設計

- node schemaが、input type、output type、params、UI field、runner read keyを明示する。
- 旧Generate tabの横断設定は、graph-wide state と node-local state に分ける。
- seed は graph-wide base seed + node-local salt の合成として扱う。
- orientation は graph-wide setting に一本化し、Result/layer projection の単一sourceとする。
- document layer は生成設定stateを所有せず、producing nodeへのprovenanceだけを持つ。
- graph-wide state evaluatorが、dirty nodes、runnable nodes、invalid edges、missing params、upstream output typeを導出する。
- preview stateは`Generate`、`Apply`、`Revert`、projection failureを明示的に持つ。
- 全paramは伝達audit matrixで証明する。
- Terrain FilterとOverlay Filterは、入力型とitem-key候補の出所を明示する。

## 完了証明の最低条件

- `Shape.width/height/radius/size/toric`の変更が出力に反映される。
- `Wall Field`、`Connectivity`、`Item Generator`の主要modeがrunnerで読まれている。
- `Source`の出力型がUI、graph model、port validation、runnerで一致する。
- node param変更がGenerate前にembedded graph resourceへflushされ、選択再同期で初期値へ戻らない。
- graph-wide orientation変更はrun cacheではなくprojectionに反映される。
- `Terrain Filter`はterrain inputだけを受ける。
- `Overlay Filter`はoverlay inputだけを受け、item-key候補をincoming overlay由来で出す。
- `Generate`単体でviewport projectionが成功し、`Apply`は確定だけを行う。
