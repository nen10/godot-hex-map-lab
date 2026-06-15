# GRAPH-11 POLICY

## 採用方針

- **model 非再実装**: graph の型・実行は `GRAPH-10`（`addons/hex_map_kit/generation/`）を呼ぶ。canvas はそれを編集・可視化するだけ。
- **依存方向**: editor → generation（一方向）。generation は editor を参照しない。
- **接続検証は model に委譲**: GraphEdit の `connection_request` で `GRAPH-10` の port 互換判定を使う。
- **LAYOUT_SKETCH_POLICY 準拠**: Build の主役は canvas、map semantics は chips、`[Generate]` を頭出し。

## Fallback / Mirror Handling

| 項目 | 有無 | 扱い |
|---|---|---|
| fallback | なし | |
| mirror | 注意 | GraphEdit 状態と model の二重持ちは **run 時に model へ一方向変換**して同期（恒久二重管理しない） |
| legacy | なし | 既存 gen_dock は変更しない（並存。retire は後続） |

## State / Invariant

| invariant | 内容 |
|---|---|
| 型整合 | 接続は `GRAPH-10` 型検証を通る |
| canvas=主役 | Build 先頭の dominant は canvas |
| 非破壊 preview | preview の run は Document を書き換えない（Promote は GRAPH-12） |

## baseline 整合
`GENERATION_GRAPH_MODEL.md`（§2/§3/§9）、`PRODUCT_DEFINITION.md` §3/§4、`LAYOUT_SKETCH_POLICY.md`、DESIGN-10 Build wireframe。
