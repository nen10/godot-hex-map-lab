# Generate Preview State Model

## 目的

`Generate -> Apply -> Generate`の順で押したときだけviewportに表示される現象を、失敗caseとして明文化する。

正しい挙動では、`Generate`単体でviewport projectionが成功し、`Apply`はそのpreviewを保持するだけ。

## preview states

| state | 意味 |
|---|---|
| `none` | previewなし。 |
| `preview_pending` | Generate後、viewport projection済み。Apply/Revert待ち。 |
| `applied` | Apply済み。生成結果を保持。 |
| `reverted` | Revert済み。生成前document/displayへ戻した。 |
| `projection_failed` | graph outputはあるがviewportへ投影できていない。 |

## run statesとの分離

run stateとpreview stateは別物。

| run state | preview stateと混ぜてはいけない理由 |
|---|---|
| `generated` | output cacheがあるだけでviewport表示を保証しない。 |
| `failed` | 失敗node表示とpreview stateは別。 |
| `stale` | cacheが古い状態とpreview pendingは別。 |

## 正しいtransition

```text
none
  -- Generate ok + projection ok -->
preview_pending
  -- Apply -->
applied

preview_pending
  -- Revert -->
reverted

none / applied / reverted / projection_failed
  -- Generate ok + projection ok -->
preview_pending

none / applied / reverted / preview_pending
  -- Generate ok + projection failed -->
projection_failed
```

## Generateの責務

`Generate`は以下をすべて行う。

1. Build contextを同期的に確保する。
2. 生成前document snapshotを取る。
3. graphを現在paramsで実行する。
4. Result優先でdocumentへpromoteする。
5. active layerへviewport projectionする。
6. projection成功なら`preview_pending`にする。
7. projection失敗なら`projection_failed`にする。

## Applyの責務

`Apply`は以下だけを行う。

- `preview_pending`を`applied`にする。
- revert snapshotを破棄する。
- Apply/Revert buttonsをdisabledにする。

`Apply`が新たにviewport projectionを発生させてはいけない。もし`Apply`後に初めてviewport表示されるなら、`Generate`時のprojectionが失敗している。

## Revertの責務

`Revert`は以下を行う。

- 生成前document snapshotを復元する。
- active layerへ復元documentをapplyする。
- preview stateを`reverted`にする。
- Apply/Revert buttonsをdisabledにする。

## 失敗case: Generate -> Apply -> Generateで初めて表示される

この現象は失敗。

想定原因:

- 1回目Generateでviewport projectionが走っていない。
- 1回目Generateでprojection target layerが未ready。
- 1回目Generateでdocumentだけ更新され、display layerにapplyされていない。
- Applyが副作用でdocument/layer applyを発生させている。
- preview stateが`preview_pending`なのに`projection_ok=false`。
- Apply後にcontext/layer/display tileがreadyになり、2回目Generateだけ成功している。

必要な証明:

- 1回目Generate直後に`viewport_apply_report.projection_ok == true`。
- 1回目Generate直後に`display_used_cell_count() > 0`。
- Apply直後にdisplay cell数が新規に増えていない。
- 2回目Generateは1回目と同じprojection経路を通る。

## shape設定が反映されない失敗case

`Shape`のwidth/height/radius/size/toricを変えても出力が変わらない場合、preview state以前にparam propagationが壊れている。

この場合は [PARAM_PROPAGATION_AUDIT_MATRIX.md](./PARAM_PROPAGATION_AUDIT_MATRIX.md) のShape行をP0として確認する。
