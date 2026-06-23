# REPAIR-11 UX

日付: 2026-06-23
状態: Codex implementation-ready

## user goal

ユーザーは、複数の item / overlay 生成を graph 上で組み合わせ、`Generate` 後に viewport と layer/document 上で何が最終結果に含まれたかを確認したい。

`Result` は「最終表示 bundle」である。ユーザーが `Result` に接続した terrain と overlays は、Generate 後に viewport preview へ一緒に現れ、Apply/Revert の対象も同じ bundle になる。

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. overlay は最後の1つだけ採用 | low | high | low | reject | どの overlay が捨てられたか分からない。 |
| B. Result に複数 overlay を暗黙接続 | medium | high | medium | reject | 順序と衝突が見えない。 |
| C. Result に明示 overlay slot を追加 | high | medium | medium | adopt | 入力一覧と順序を UI / test で証明できる。 |
| C-1. unlimited dynamic slots | high | medium | high | defer | 今回は Codex 実装可能性と proof の明確さを優先する。 |
| C-2. fixed `overlay_0..overlay_2` slots | high | low | medium | adopt for this repair | 3本で multi-overlay contract を証明でき、GraphEdit 操作も単純。 |
| D. Compose node で合成してから Result | medium | high | high | reject | Compose と Result の責務が重なる。 |

## expected experience

1. ユーザーは `Shape` などで terrain を作る。
2. 複数の `Item Generator` または `Source Overlay` を作る。
3. `Result.terrain` に terrain を接続する。
4. `Result.overlay_0`, `Result.overlay_1`, `Result.overlay_2` の任意 slot に overlays を接続する。
5. `Result` inspector / selected snapshot に overlay 一覧が見える。
6. `Generate` で terrain と全 overlay が viewport に出る。
7. `Apply` で各 overlay が別 generated overlay layer として保持される。
8. `Revert` で terrain と overlay が一緒に戻る。

## Result node visual contract

Minimum visible rows:

```text
Result
  terrain     [terrain input]     -> out: result
  overlay_0   [overlay input]
  overlay_1   [overlay input]
  overlay_2   [overlay input]
```

Allowed simplification for this repair:

- The output port may remain on the first row if that is the existing GraphEdit pattern.
- Overlay slots may be always visible even when unused.
- No plus/minus overlay slot buttons are required.

Not allowed:

- A single generic `overlay` row as the only overlay input.
- Hidden multiple connections to one input row.
- A Result node that visually suggests it accepts another Result output.

## Result inspector / snapshot

Minimum display/proof information:

| 表示 | 意味 |
|---|---|
| terrain input | Result の主 terrain; missingなら Generate は invalid |
| overlay inputs | connected overlay ports in order, e.g. `overlay_0`, `overlay_1` |
| overlay order | numeric suffix order |
| overlay count | number of Result overlays included in output |
| conflicts | same item key + same cell across overlay inputs |
| projection status | viewport に投影済みか |
| generated layer ids | `generated_overlay_0`, `generated_overlay_1`, ... |

If adding these to the visual inspector is too invasive, the minimum acceptable implementation is to expose them in the existing Build screen debug snapshot used by tests, plus a concise status label after Generate:

```text
Generated preview shown in viewport (result): 1 terrain, 2 overlays.
```

## Layer/document UX contract

After Generate/preview from a Result with two overlays:

```text
Terrain Layers
  Generated Terrain

Overlay Layers
  Generated Overlay 1    # from overlay_0
  Generated Overlay 2    # from overlay_1
```

The user must be able to inspect that two overlay layers exist. They must not be merged into a single generated overlay layer.

Layer ids should be deterministic:

- `generated_overlay_0`
- `generated_overlay_1`
- `generated_overlay_2`

Display names should be human-friendly:

- `Generated Overlay 1`
- `Generated Overlay 2`
- `Generated Overlay 3`

## Conflict UX

Conflict warning is informational in this repair:

- It must not block Generate.
- It must not merge overlays.
- It must appear in metadata/snapshot; UI label is preferred but not required.

Minimum status behavior:

```text
Generated preview shown in viewport (result): 1 terrain, 2 overlays, 1 conflict warning.
```

If status text becomes too long, debug snapshot/test proof is enough for this repair.

## rejected UX

- `Result` receiving `result` input.
- `Compose` as primary final-output path.
- overlayが最後の1つだけに折りたたまれる flow。
- overlayが1枚の generated overlay layer に silent merge される flow。
- graph cache summary だけで成功に見える flow。
- bundled sample graph だけを proof にする flow。
