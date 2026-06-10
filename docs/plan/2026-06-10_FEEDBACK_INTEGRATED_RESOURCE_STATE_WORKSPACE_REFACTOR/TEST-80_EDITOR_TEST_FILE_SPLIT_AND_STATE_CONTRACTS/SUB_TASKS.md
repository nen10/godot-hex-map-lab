# TEST-80 Editor Test File Split And State Contracts Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Add focused state/contract test scripts. | Adopt | State machines and screen contracts should be testable without expanding the monolithic editor integration file. |
| Add the new scripts to `tools/test.sh`. | Adopt | Standard verification must run the split coverage. |
| Keep integration-heavy editor flows in `test_editor_plugin.gd`. | Adopt | A full mechanical move is high risk and not required to prove the split. |
| Remove duplicated private widget-shape assertions when state/snapshot contracts cover the same behavior. | Adopt | The roadmap asks to replace old UI shape tests where they preserve bad UX. |
| Add analog tests. | Reject | CLEAN UI work explicitly defers new analog tests. |

## Scheduled Task

No follow-up task is scheduled from this slice. Further mechanical splitting can continue later after the new focused scripts stabilize.
