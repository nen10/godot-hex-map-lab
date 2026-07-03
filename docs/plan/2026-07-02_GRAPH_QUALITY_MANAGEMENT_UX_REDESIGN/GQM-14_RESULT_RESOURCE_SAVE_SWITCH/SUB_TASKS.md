# GQM-14 Result Resource Save/Switch — Sub Tasks

## Complexity

Class: C3
Reason:
- The task crosses adapter resource serialization, Build screen UI state, project asset listing, viewport preview state, and promote behavior.
- The UX state is small, but correctness depends on preserving Apply/Revert semantics and proving saved results switch without running the graph again.

Required artifacts:
- SUB_TASKS.md
- UX.md
- POLICY.md
- IMPLEMENTATION_PLAN.md
- self-review after execution

## Task Resolution Candidate Matrix

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Add result save/list/switch to Build header action row | Saved generated output can be named, listed, selected, previewed, then applied or reverted | adopt | Matches the contract placement near Apply/Revert and keeps graph canvas primary. |
| B. Add thumbnail browser | Visual comparison | reject | Roadmap and contract explicitly prohibit thumbnails. |
| C. Save graph snapshot + seed only | Lighter files | reject | DESIGN_DIALOGUE Q-R2-3 selected data-included save to avoid regeneration on switch. |
| D. Store result through park score/validation fields | Reuse old fields | reject | RESOURCE_MODEL limits written fields and parks score/validation. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Thumbnail preview/list | none | reject | Explicitly forbidden by roadmap and contract. |
| Score/validation result management | none | reject | Park fields are out of scope for this result asset path. |
| Batch result comparison | none | reject | Batch comparison was removed by GQM-13 and parked by roadmap. |

## Scheduled Tasks

None. GQM-14 is implementable as one completion boundary.
