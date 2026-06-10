# NEXT-00 UX

## User Goal

Maintainers should be able to continue from the completed refactor roadmap into a new queue that captures UI metric testing and every actionable deferred requirement, without losing work in prose-only notes.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Append tasks to the completed refactor queue | medium | high | low | reject | It blurs completion proof for the previous roadmap. |
| B. Create a new follow-up roadmap and queue | high | low | medium | adopt | It gives the new feedbacks their own source of truth and pointer. |
| C. Only implement UI-METRIC-00 from the feedback file | medium | high | low | reject | It drops the unqueued extract and repeats the prose-only problem. |
| D. Start with implementation debt before process guardrails | medium | medium | medium | reject | Large follow-up tasks need better planning and deferred-item tracking first. |

## Adopted UX

- A new roadmap explains why process guardrails and UI metrics precede larger UI work.
- The implementation queue contains every actionable feedback item as a task or an explicit policy-deferred item.
- The first task proves adoption and leaves `PROCESS-10` as the next concrete READY task.

## Deferred UX

- No analog/manual visual test is created.
- No package upload is automated.

## Experience Steps

1. Read the new roadmap.
2. Check the queue pointer.
3. Run the first READY task.
4. After adoption, continue into process guardrails and UI metric contract tasks.

## Existing UX Interference

The completed 2026-06-10 refactor queue must remain complete and not be reopened for unrelated follow-up work.
