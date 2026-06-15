# RESCTX-42 UX

## 達成したい体験
- Resources を開くと「この map の資産」が Unique/Shared/Optional で分かる。
- 足りないものは `[Create Missing Resources]` 一発で揃う。
- 他タブの先頭は **chip だけ**で、詳細を見たければ Resources に行く。

## 避ける体験
- 先頭に `Readiness Summary` / `Next actions:` / `Shared resources:` のラベル列（現状/U1・U6）。
- 各タブ先頭に詳細 resource row が並ぶ。

## UX Candidate Matrix
| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| Resources | A: 資産棚 card / B: ラベル列 | **A** | 「棚」として読める |
| 不足 | A: 大 CTA / B: テキスト | **A** | 一発で揃える |
| work tab | A: chip / B: row | **A** | 主作業面を前に |
