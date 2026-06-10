# PROC-90 Final Dist Regeneration Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Run `tools/package_addon.sh` against `dist/`. | Adopt | The roadmap requires committed dist artifacts to be regenerated at the final process step. |
| Compare regenerated `dist` manifest/zip changes through git diff/status. | Adopt | Acceptance requires recording whether committed artifacts changed. |
| Run `./tools/test.sh` after regeneration. | Adopt | Autopilot completion still requires the standard verification gate. |
| Add dist freshness to `tools/test.sh`. | Reject | The roadmap explicitly keeps dist freshness outside normal test gates. |
| Upload or publish the generated zip. | Reject | Public release upload is a manual external release step, not an autopilot task. |

## Scheduled Task

No follow-up task is scheduled from this slice. Public upload remains a manual release action outside the queue.
