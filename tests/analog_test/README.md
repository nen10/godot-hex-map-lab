# analog_test

このディレクトリは、ユーザー依頼時に作成するアナログテストの操作手順マニュアルと検証記録を置く場所です。

アナログテストの policy は `docs/policy/ANALOG_TEST_POLICY.md` を参照します。

## CLEAN UI rework status

- CLEAN UI再編中、新規アナログテスト文書は作成しません。
- このディレクトリ内の既存文書は history / reference です。
- 既存文書は clean UX acceptance や current Test path の代替ではありません。
- NEXT-03-style analog test pack は現在の roadmap queue には scheduled されていません。
- UI改善後にユーザーが明示した場合だけ、新しいアナログテスト作成を再開します。

ファイル名:

```text
<USE_CASE_ID>_ANALOG_TEST_<YYYY-MM-DD>.md
<USE_CASE_ID>_CHATGPT_JUDGEMENT_<YYYY-MM-DD>.md
```

コードリーディング検証は `docs/review/<USE_CASE_ID>_CODE_READING_<YYYY-MM-DD>.md` に記録します。

ここに置く文書は、製品 manual や仕様書ではなく、Editor Plugin 操作を使った任意実施の検証手順と観察記録です。
