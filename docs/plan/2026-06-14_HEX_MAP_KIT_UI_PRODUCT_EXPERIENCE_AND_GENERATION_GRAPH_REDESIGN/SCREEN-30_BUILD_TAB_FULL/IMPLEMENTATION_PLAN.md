# SCREEN-30 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Build tab の simple/graph 両立と仕上げ（preview/promote/dirty）。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/generation/hex_generation_preset.gd   # Generation Profile → preset graph
addons/hex_map_kit/editor/hex_map_build_screen.gd        # Simple 帯 + canvas 一体化 + 状態表示
tests/test_build_screen_full.gd
```

## preset graph factory
`HexGenerationPreset.from_profile(profile_res) -> graph(Dictionary)`
- 基本 chain: `shape(profile.shape/size) → wall_field(profile.wall_probability, seed) → connectivity(profile.method)`。
- 出力 terrain を promote 既定 role=terrain に向ける。
- profile が無ければ最小デフォルト（rectangle + 中庸 wall_probability）。

## Simple 帯 UI（canvas 上部）
```
( Map: … )( Catalog: … )( Target: … )           [ Generate ]
 Profile: [ ▼ tactical_basic ]   [ Generate (Simple) ]      # preset graph を生成・run・promote
─────────────────────────────────────────────────────────
 [ GraphEdit canvas (dominant) ]        | preview |
─────────────────────────────────────────────────────────
 Selected node: …   Promote: [role ▼]   Last run: …   ● dirty
```

## 状態表示
- preview（選択 node / 最終 map）
- Promote 先 role（GRAPH-12）
- dirty / last run（GRAPH-13）

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| simple 出口 | preset が canvas に出ない | profile→Generate(Simple) 後、canvas に preset graph node が現れる |
| 一体化 | simple/graph 別物 | Simple 生成後そのまま node を足して再 Generate できる |
| 主役 | canvas が主でない | Build dominant が canvas |
| 状態 | promote/dirty 不可視 | promote 先 role と dirty が表示される |

## Planned steps
preset factory → Simple 帯 → 一体化 → 状態表示 → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task SCREEN-30 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: preset graph factory / canvas 一体 / preview・promote・dirty 表示。
- E: 初心者は Profile→Generate、上級者は graph、両方が最初の画面から辿れる。
- `./tools/test.sh` green。
