# Build Generate viewport表示 修復設計の明確化

日付: 2026-06-22
関連handoff: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
関連修復matrix: `docs/development_log/2026-06-22_BUILD_GENERATE_VIEWPORT_PREVIEW_REPAIR_MATRIX.md`

## 目的

この文書は、Buildの`Generate`修復で混乱した点を切り分けるためのもの。

重要なのは、`Generate`の結果を「node preview / thumbnailに出た」と扱わないこと。完了証明は、Godot 2D viewport上の実際の`HexTileMapLayer`に生成結果が表示されること。

今回の修復はBuild tab全体の再設計ではない。主対象は、`Generate`を押したあとに生成結果がviewportへ投影される経路の修復。

## 訂正した判断

四角いtile panelは、今回ユーザーが求めたviewport表示ではない。

`HexMapPreviewThumbnail`は、graph nodeの出力概要やsnapshot用の軽量previewであり、Buildの主結果ではない。Build `Generate`の完了証明として、thumbnailだけを使ってはいけない。また、目に見える「四角tile panel」をGenerate結果として復活させてはいけない。

## 決定事項

| 項目 | 決定 |
|---|---|
| `Generate`の主結果 | Godot 2D viewportに生成結果を表示する。 |
| 対象layer | 選択中の`HexTileMapLayer`を使う。なければ`BuildHexMapLayer`を作成して選択する。 |
| context取得 | Build画面は実行前に同期的に対象layer/document/graphを取得する。 |
| preview確定model | 生成結果は`Apply`までpending preview。`Revert`で生成前のin-memory documentとviewport表示へ戻す。 |
| thumbnail / 四角panel | Build完了UIにも完了証明にも使わない。snapshot上で残る場合も二次的情報。 |
| 完了証明 | viewport projection report、対象layer path、display cell数を必須にする。cacheやthumbnailのみは不可。 |

## 必須snapshot証明

Build `Generate`の証明には以下を含める。

- `viewport_preview_visible`
- `viewport_preview_layer_path`
- `viewport_preview_cell_count`
- `preview_commit_state`
- `viewport_apply_report.projection_ok`
- 対象layerの`display_used_cell_count() > 0`

thumbnail payload、graph cache、candidate preview snapshotは他用途では残ってよい。ただしBuild `Generate`成功の証明にはならない。

## 完了証明として拒否するもの

| 拒否する証明 | 理由 |
|---|---|
| thumbnailだけのpreview | 出力dataの存在は示せても、viewportに見えていることは示せない。 |
| sampleだけの成功 | sampleは学習・onboarding用であり、production featureの証明ではない。 |
| graph cacheだけのtest | cacheがあってもviewport投影が失敗する可能性がある。 |
| 目に見える四角preview panel | 必須のviewport-firstな結果表示と競合する。 |

## 残るfollow-up

今回のhotfixでは解決しない。

- graph-wide generation state model。
- Region Filterのitem-key UX。
- graph canvasの操作性とlayout。
- edge deletion。
- Resultのmulti-overlay契約。
- intermediate outputのscene child node化。
- Markov Mesh / adjacency rulesの旧Generate意図との対応確認。

## process note

前回計画の「thumbnailをsecondaryとして残す」という表現は、四角tile panelをGenerate結果として正当化するように読める曖昧さがあった。正しい扱いは、thumbnailをBuild完了証明から除外すること。

また、UI文字サイズについて「小さくする」だけを設計条件にしてはいけない。Godot editor上で読む画面であり、モバイルUIではないため、視認性を落とすfont縮小は不可。文字は既存editor UIと同等以上に読めることを優先する。
