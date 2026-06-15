# DOC-70 SUB_TASKS

## Complexity

Class: C2
Reason:
- docs-only workflow rewrite across manual and README.
- Existing product direction is already fixed by roadmap and product definition.
- No API/UI behavior changes are required.

Required artifacts:
- `UX.md`
- `POLICY.md`
- `IMPLEMENTATION_PLAN.md`
- self-review and proof log

## Task Resolution

Rewrite end-user workflow documentation around the current product path:

```text
Build graph -> Promote layer -> Paint -> Export handoff
```

Resource selection, Catalog, Layers, and Resources remain support shelves. QA/Validate remain parked/supporting and must not be presented as the main production route.

## Scope

含む:
- `docs/manual/MANUAL_WORKFLOW.md` を作業目的ベースへ更新。
- `README.md` の editor authoring summary を新導線へ更新。

含まない:
- Editor UI 実装変更。
- analog test 作成。
- package/dist regeneration。
- `MANUAL_EDITOR_PLUGIN.md` 全体改稿。

## Candidate Matrix

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| manual structure | A: Build/Paint/Export first / B: Resources list first | **A** | Roadmap Y7 requires work-purpose flow. |
| support tabs | A: shelves/support / B: main route | **A** | Product definition says Catalog/Layers/Resources support semantics; QA/Validate parked. |
| samples | A: learning/onboarding only / B: default production route | **A** | No sample-only completion. |

## Scheduled Task Audit

なし。

## Sub-tasks

1. Add first-pass workflow steps: Build graph, Promote generated layer, Paint finish, Export handoff.
2. Move resource preparation into support shelves instead of the primary route.
3. Keep sample/debug/package boundaries explicit.
4. Update README summary to match the manual.
