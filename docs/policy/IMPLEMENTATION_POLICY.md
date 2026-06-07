# Implementation Policy

## Purpose

計画済み task を実装するときの判断基準を定める。

実行手順は `docs/process/`、テスト設計は `TEST_DESIGN_POLICY.md` に従う。

## Principles

- 実装は Roadmap と task plan を満たすために行う。
- 未公開 addon では、互換性維持をデフォルト要件にしない。
- clean Resource / clean API / clean UI を優先する。
- fallback / hack / legacy は仕様根拠にしない。
- UI の根拠はゲーム開発上の UX合理性であり、headless test の都合ではない。
- No sample-only completion: sample preset だけで成立する UI は `sample-only prototype` であり、production feature completion ではない。
- completion proof は、通常導線で任意 project asset を選べること、または未選択状態と validation issue が明示されることを含む。

## Scope control

- task の acceptance を満たすために必要な code / tests / docs を同じ作業で更新する。
- task 外の大規模 redesign は follow-up に分ける。
- 作業中により清潔な仕様が必要だと判明した場合、互換維持ではなく plan / queue を更新して進める。

## Resource / API changes

- canonical schema を優先する。
- v1/v2、migration、compatibility は Roadmap が明示した場合だけ扱う。
- Resource reference を優先し、path string を通常 API の主語にしない。

## UI changes

- path text、raw JSON、numeric fallback を通常導線にしない。
- bundled sample asset は learning / onboarding path として扱い、通常導線の silent default や completion proof にしない。
- UI は作業目的ごとに整理する。
- 古い UI test が変更を妨げる場合、test を新 UX の state contract へ更新する。

## Verification

- `docs/TEST.md` に接続する自動テストを基本根拠にする。
- UI feature の headless test は sample mode OFF または user-selected project asset state を確認し、sample mode ON/OFF は別 contract として扱う。
- UI の視認性・操作感は headless test で固定しない。
- CLEAN UI 再編中は新規 analog test を作らない。必要な観察項目は deferred として残す。

## Completion review

- acceptance を満たしたか。
- sample-only prototype を complete と誤判定していないか。
- `repair-now` が残っていないか。
- Test path と self-review があるか。
- follow-up が必要なら queue に追加できる形で整理したか。
