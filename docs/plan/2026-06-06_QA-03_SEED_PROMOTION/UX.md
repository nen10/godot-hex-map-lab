# QA-03 Seed Promotion UX

## Goal

After comparing generated seeds, a user should be able to promote a chosen candidate into a Level Document v2 resource. The promoted document must carry enough generation metadata to reproduce or audit the candidate later.

## Operation Steps

1. User generates or reviews a batch score table.
2. User chooses a candidate seed row.
3. The dock regenerates that seed from the stored generation snapshot.
4. The dock returns a v2 document with terrain data and generation metadata.
5. The document can be saved or passed to later editor workflows.

## Scope

- Add headless promotion helpers for seed and batch-row promotion.
- Store seed, sanitized generation snapshot, score, and validation summary in document metadata.
- Keep visible UI work optional; QA-03 verifies the editor adapter path by tests.

## Nonblocking Manual Check

- A later UI task can add a visible Promote button and selected-row affordance.
