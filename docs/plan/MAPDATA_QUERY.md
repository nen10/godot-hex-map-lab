## MAPDATA_QUERY.md



### マップデータ生成後のデータ自動保存機能(Generate History)を追加する

- チェックによるOn/Off可能
- 保存ディレクトリのみ指定可能とし、ファイル名は作成日時-簡潔な実行条件名-主な生成タイル名を含むようにする。
- 生成キャンセル時は保存不要。

### 保存済みの生成マップデータ の読み込み機能

  - 名前付き source として Dock 内に任意の個数保持する。
  - 自動保存によるMapdata生成時、自動で追加していく。マップデータの表示名はファイル名に従う。
  - 保持中の生成マップデータは個別にClear可能。
  - Mask / Reference source は 保持されているマップデータのうち、任意にユーザーが選択したMapdata.ItemKeyを任意の個数並べてqueryを作成する領域として扱う。`Primary current`、`Current Overlay`、`Loaded Overlay Resources` のような分類ではなく各行をItemKeyとする。

- マップデータの表示名はファイル名に従う。resource path 表示、読み込み解除、再読み込み、同名 resource の扱いを計画する。
- `TileMapLayer` 直接参照によるマップデータ取得は不要。
- TileMapLayer から生成マップデータは復元しない。

### query作成用ItemKeyList

query作成の集合演算子が全てをand結合するかor結合するかの扱いになっているが、あまりよろしくない。query作成用のMapdata.ItemKey指定の方法を変更する。

  - 保持されているマップデータ.ItemKeyのコンボボックスを選択し、query作成領域に該当のItemを行として追加する。
    - 各アイテム行は[{and,or}],[ItemKey名],[{Contain, Exclude}分類]を持ち、二つ目以降のアイテム行についてのみ[{and,or}]の集合演算子選択項目を有効とする。
    - アイテム行は順番を上下に移動できる。
    - アイテム行は削除できる。
    - アイテム行ごとにCell座標の平行移動を可能とする
      - 六方向近傍タイルのクリックにより、その方向の平行移動量の数値をインクリメントする
        - 向かい合う方向が正だったらそちらをデクリメントする。
  - Mask用のquery作成領域について
    - [Crop]チェックボタンを持つ。
      - On変更後、現在選択されているShape,サイズデータでcropする。
      - 保持中の生成マップデータのShapeがsquareの場合のみ、参照元マップは本来のcyclic_sizeに従うことでToricに座標計算することを可能とする。ただし、平行移動処理含めたToricな座標計算には数学的に注意し堅実なテストを行うこと。
      - Cropデータにおいて、ItemKey = "Any"を現在選択されているShape,サイズデータに基づく座標全体として保持する。
    - [Crop]On後、生成可能な該当Cell数を表示する。これは"Any"及び重複Cellを除いたを全ての座標の個数である。
    - [Crop]後 Tileチップ選択用の設定領域(query作成領域とは独立である)を有効化する。このTileチップ選択はItemKeyとは関係なく、全Cellが同一のTileである。マスク領域確認目的の単一Tile設定である。(Apply: "Any"以外のCellにTile配置する。)

### ボタン処理:[Apply layer], [Save .tres]

既存 [Apply layer], [Save .tres]について"ボタンによる実行"はその機能を変更する。

- Overlay時、[Crop]後のみボタンを有効化する。元々の機能は自動Apply, 自動保存により代替されるため不要。
  - [Apply layer] / Overlay : Mask用のquery作成により、cropされたデータを一つのマップデータとしてApplyする。(Apply layer -> Show Maskみたいな名前に変更)
  - [Save .tres] / Overlay : Mask用のquery作成により、cropされたデータを一つのマップデータとして保存する。
  - excludeを指定したItemKeyはマップデータに含まないことに注意する。
