# DESIGN-11 UX

## 対象 user

dock を開いた直後、「今どの map を、どの順で作るか」を知りたいゲーム開発者。

## 達成したい体験

- dock を開くと **global top strip** に「今の map / 状態 / 作業の進み（Build ▸ Paint ▸ Export）/ 足りないもの」が出る。
- 重要タブ（Build/Paint）が前方で、支援（Catalog/Layers/Resources）・utility（Export/Settings）と**重みの差が一目で分かる**。
- 未設定時は top strip が**次の行動 CTA**を出す（「Missing: Tile Catalog → [Choose]」）。
- QA/Validate は主導線から外れ、必要時のみ **Diagnostics** から開く。

## 避ける体験

- 9個のタブが同列・同重みで並び、どこから始めるか分からない（現状）。
- 進行や次の行動が**どこにも表示されない**。
- QA という語が主面にあり、何の画面か分からない（park へ）。

## UX Candidate Matrix

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| 始点提示 | A: global top strip に導線+CTA / B: 各タブ任せ | **A** | 「始点不明」を1箇所で解消 |
| 進行表示 | A: `Build ▸ Paint ▸ Export` step + current 強調 / B: 文章 | **A** | 一目で順序が分かる |
| 未設定 | A: top strip に Missing CTA / B: 各タブの empty 任せ | **A** | global に次の一手を出す（empty は DESIGN-10 が各タブで担保） |
