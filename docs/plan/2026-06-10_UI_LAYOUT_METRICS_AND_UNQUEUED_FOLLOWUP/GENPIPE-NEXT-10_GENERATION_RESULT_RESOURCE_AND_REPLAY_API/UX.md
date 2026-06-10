# GENPIPE-NEXT-10 UX

## User Job

A developer compares generated candidates, inspects what data each candidate owns, and promotes the chosen result knowing the final Level Document came from the same candidate object.

## Required Visible State

| state | UX requirement |
|---|---|
| Candidate Resource | Generate/QA rows expose a result Resource identity. |
| Scope | Result state identifies primary map, overlay map, candidate document, validation result, and preview availability. |
| Replay | A generated result can replay to a Level Document without rerunning unrelated UI state. |
| Promotion | QA promotion marks that the promoted document came from a replayed result Resource. |

## First Impression Bar

- QA rows should feel like durable candidates, not transient table text.
- Promotion should preserve seed, validation summary, score, and result id metadata.
- The graph/pipeline future work must remain out of the visible product surface for this task.

## Rejections

| rejected option | reason |
|---|---|
| Row dictionary only | Does not establish the Resource/API boundary requested by the roadmap. |
| Graph visualization | Belongs to `GENPIPE-NEXT-20`. |
| Regenerate on promotion only | Promotion should replay the selected result when available. |
