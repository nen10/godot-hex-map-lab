# DOMAIN_POLICY.md

## 目的

実現するUXを開発領域に分解しながら設計を行う指針を定める。

## 開発領域

Document / Core / Adapter / UI / 自動テスト のこと。

## (コードベース含む) Document 

- 責務: 実体ファイル 作成/編集/解釈 のきっかけを提供する。

### コードベース 及び Document の作成・編集

本ドキュメント含む `docs/policy/` 以下の Documents を参照。


- `docs/policy/DOMAIN_POLICY.md`
  - 開発領域ごとのファイルの扱いに関する方針を定める。本ドキュメント。

- `docs/policy/PLANNING_POLICY.md`
  - 設計書作成の方針 Design Flow を定める。

- `docs/policy/IMPLEMENTATION_POLICY.md`
  - コードベース作成・編集の方針 Implementation Flow を定める。

- `docs/policy/TEST_DESIGN_POLICY.md`
  - 自動テスト設計の方針を定める。
  - テストケースの存在は開発の結果であって、今後の開発や設計の根拠ではない。

- `docs/policy/ANALOG_TEST_POLICY.md`
  - 操作手順文書(アナログテスト)作成の方針を定める。
  - アナログテストはUX検討を具体化する操作手順と観察点を提供する。


### コードベース検討・Document解釈

- fallback および hack 挙動は実装上の一時的な状態として扱う。
- ドキュメントに存在する fallback 処理や hack 体験フローの記載は、一時的な対応報告であり、仕様や UX デザインの根拠にしない。
- docs だけを根拠に実装済みとは判定しない。実装状態は `docs/TEST.md` に接続された test、コード、または明示された review によって確認する。
- manual は仕様書ではない。実装した事項の一覧でもない。計画されたUXをユーザーに対してサポートする手順・情報である。


## Core

- 責務: 汎化された構造的な機能についてのAPIを提供する。

### Core設計

- Core 機能は抽象化され、結果的に UX として利用されない実行パスの余地を含む設計にも注目する。
- UI で採用しない実行パスが存在しても、Core の schema や helper として後続実装に利用できる場合は維持できる。

この抽象性は Core 機能において目指す。UX は簡潔に設計すればよく、すべての Core 機能を活用するための冗長な UX は不要である。

## Adapter

- 責務: 柔軟なUXを実現するため、Core機能とUIを接続する。

### Adapter設計

- Core schema を UI 操作へ直接露出させず、resource / scene / TileMapLayer 状態への変換責務を Adapter に置く。
- UI の簡潔さと Core の汎用性が衝突する場合、Adapter で接続方法を調整する。

## UI

- 責務: 特定のUXを実現するための表示と操作機能を提供する。

### UI層の設計

- UX 説明から具体的な固有名詞を減らしても Operation Steps が一意に定まるような設計に注目する。
- 類似した複数のノードやリソースを示す型を使い分ける場面を減らせる設計に注目する。

たとえば、generate 用 dock と manual edit 用 dock とで、使用するノードやリソースの一貫性を高め、UX 説明の簡潔さを確保する。
この簡潔さは UI 層において目指す。Core 実装では、最適化された schema に基づいたデータ構造を活用してよい。


## 自動テスト

- 責務: 機能実装の完了判断を提供する。

### 自動テスト設計

`docs/policy/TEST_DESIGN_POLICY.md` に従う。
ただし、UX改善に干渉するテストケースが判明した場合はテストの修正・削除を計画に含める。
