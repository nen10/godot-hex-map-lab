# REPAIR-10 Policy

## source of truth

- product baseline: `docs/design/PRODUCT_DEFINITION.md`
- generation graph baseline: `docs/design/GENERATION_GRAPH_MODEL.md`
- handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
- design system reference: `docs/policy/design-system.md`

## 守るべき規則

- Build graphは製品のbackbone。
- sample成功だけではproduction proofにならない。
- UI first impressionはcompletion evidenceである。
- `Generate`完了証明はviewport projectionであり、thumbnail/cacheの存在ではない。
- 新しいgeneration engineは作らない。
- この修復で新しいResource schemaは作らない。
- 新しいanalog testは作らない。
- 完了済みroadmap taskを再openせず、このrepair taskとfollow-up taskで管理する。

## Apply / Revert規則

生成結果は、ユーザーが`Apply`を押すまではpreview pending状態。

- `Apply`はrevert snapshotを破棄し、previewを保持済みにする。
- `Revert`はprojection前のterrain/overlay/object document stateを復元し、viewport表示も再適用する。
- viewport projectionが失敗している場合、`Apply`は禁止する。

## projection成功規則

`viewport_preview_visible`がtrueになってよいのは、以下をすべて満たす場合だけ。

- preview stateが`preview_pending`または`applied`。
- active layerが存在し、scene tree内にある。
- `ensure_display_tiles()`が成功している。
- layer display statusにtile sourceがある。
- layer apply reportが成功している。
- `display_used_cell_count() > 0`。

## follow-up分離

以下は重要だが、このrepairの範囲外。

- multi-overlay Result resource contract。
- intermediate output child node model。
- graph-wide state evaluator。
- Region Filter item-key / dropdown UX。
- edge deletion interaction。
- Markov Mesh / adjacency rulesと旧Generateの完全な対応。

これらをREPAIR-10の完了条件に混ぜてはいけない。また、REPAIR-10のtestで暗黙に完了扱いしてはいけない。

## 文字サイズ方針

Build graphはdesktop/editor UIであり、モバイル向けの小型UIではない。小さくして収めることより、読めることを優先する。

- 文字サイズの下限は既存Godot editor UIと同等の可読性を基準にする。
- 12px級の縮小を設計要件として固定しない。
- node幅、wrap、layoutの調整で文字切れを避ける。
