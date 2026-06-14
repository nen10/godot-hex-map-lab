# STATE-NEXT-10 Policy

## Adopted Decisions

- Keep event constants for caller compatibility, but resolve them through typed enum + registry.
- Replace loose action payload storage with explicit concerns in dispatch result.
- Keep existing workspace side effects in handlers while exposing them in `side_effects`.
- Maintain compatibility for workspace-facing consumers by updating tests and call sites in this task.

## Rejected Decisions

- Remove typed event descriptor mapping and keep raw string branches.
- Return only legacy `result` payload.
- Ignore null workspace / unknown event as a normal fallback path.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---
| Legacy key `result` in dispatch output | reject | It is no longer the primary output contract | `STATE-NEXT-10` completion |
| Null workspace event dispatch | keep | Safety contract for accidental call sites | Existing test coverage |
| Unknown event dispatch | keep typed failure | Prevent silent no-op behavior | Existing test coverage |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| `ok/error` envelope | Must remain for existing consumers | regression to old consumers | `test_editor_plugin` dispatch assertions |
| `reducer_result` | Must represent action-relevant output only | conflation with UI update metadata | new dispatch contract assertions |
| `side_effects` | Must describe requested/performed imperative behavior | missing behavior trace | new dispatch contract assertions |
| `ui_state_update` | Must describe which UI surfaces should refresh | stale UI state updates | existing and new UI contract tests |
| `debug_report_proof` | Must be sourced from workspace debug report API | fabricated data risk | all existing and new assertions |
