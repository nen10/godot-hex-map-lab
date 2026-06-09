# FB-00 UX

## User Goal

Adopt all feedback into a single executable roadmap so the next Codex autopilot run does not have to re-interpret competing notes. A contributor should be able to open the roadmap and queue, see the source priority order, and start the next READY task without asking for human approval.

## Operation Steps

1. Read the active roadmap and implementation queue.
2. Confirm all four feedback documents are named as inputs.
3. Confirm the priority order is explicit:
   - HexTileMap Resource Refactor feedback.
   - UI State Transition Refactor feedback.
   - UI First Impression feedback.
   - Roadmap Execution Evaluation feedback.
4. Confirm early-safety exceptions are explicit: FileDialog lifecycle repair and visible no-op control repair.
5. Confirm `dist` freshness is final-process-only.
6. Confirm new analog tests are deferred during CLEAN UI work.
7. Leave the queue with the next READY task visible after `FB-00`.

## Adopted UX

- Roadmap readers get a single source of truth instead of switching among feedback files.
- Next tasks preserve the requested priority order while allowing urgent visible repair to happen early.
- Completion evidence is queue proof, self-review, and standard test execution, not sample-only behavior.

## Retained UX

- Feedback source documents remain available as detailed reference material.
- Existing `./tools/test.sh` remains the standard verification command.
- Existing analog tests remain historical/reference material only.

## Removed Or Deferred UX

- New analog tests are not created in this task.
- `dist` regeneration is not performed in this task.
- FileDialog and visible no-op fixes are not mixed into this adoption proof task.

## Existing UX Interference

Old UI shape, sample fallback, path text, debug label, and numeric fallback expectations must not override the new roadmap. Those conflicts are resolved in later tasks by Resource ownership, state transition, and first-impression UI rules.
