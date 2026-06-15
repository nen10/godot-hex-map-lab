# GRAPH-13 IMPLEMENTATION_PLAN（pre-execution）

## Scope
run engine の dirty/cancel/progress + N batch(降格) + 失敗 node 可視。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/generation/hex_generation_graph_runner.gd  # dirty 伝播 / interrupt_options
addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd       # 失敗 node 強調
addons/hex_map_kit/editor/hex_map_build_screen.gd             # [Generate] 頭出し / busy / cancel / N batch panel
tests/test_generation_graph_runner_dirty.gd
```

## dirty 伝播
- runner が node ごとに `output cache` + `dirty` を持つ。
- node param/接続変更 → その node と **全下流**を dirty。
- run 時、dirty node のみ再計算（上流 cache 再利用）。

## cancel / progress
- `runner.run(graph, context)` に `context.interrupt_options` を渡し、各 node run（generator の `*_interruptible`）へ伝播。
- busy 中は `[Cancel]` 表示。cancel 後は部分結果を Document/preview の確定に使わない。

## N batch（降格 UI）
- 下方 panel: `N`(SpinBox, default 1) / `Randomize seed`(off) / `Randomize shape`(off) / `[Generate N]`。
- N>1: 同 graph を seed/shape を振って N 回 run → 結果束（preview 一覧）。promote は1つ選んで実施（GRAPH-12）。

## 失敗 node 可視
- `validate`/run の error.node → GraphNode を強調色 + tooltip に msg。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| dirty | 全 run してしまう | 下流 node だけ変更 → 上流 cache 再利用（再計算回数を test で確認） |
| cancel | cancel 効かない/不整合 | 長い run を cancel → 中断、Document/preview 未確定 |
| N=1 既定 | 初期で N>1 | 初期状態 N=1・randomize off |
| 失敗可視 | 場所不明 | 不正 graph run → error.node が強調される |

## Planned steps
runner dirty/interrupt → canvas 強調 → screen busy/cancel/N panel → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task GRAPH-13 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: topo + 中間 cache + dirty 伝播 / N default 1。
- E: primary `Generate` が上部明白 / 束生成は副次 / 失敗 node が分かる。
- `./tools/test.sh` green。
