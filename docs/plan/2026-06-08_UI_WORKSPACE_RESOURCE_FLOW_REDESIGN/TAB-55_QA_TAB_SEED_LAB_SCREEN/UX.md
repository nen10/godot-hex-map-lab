# TAB-55 UX

Task: `TAB-55_QA_TAB_SEED_LAB_SCREEN`

The QA tab compares generated seeds and promotes one result into the project Level Document. Generate remains the single-candidate generation workspace; QA is the multi-seed evaluation workspace.

Primary screen:

1. Show the selected Generation Profile and Validation Rule Suite.
2. Show Seed Lab rows sorted by score.
3. Show selected seed preview and validation summary.
4. Show the promotion target Level Document relationship.
5. Promoting a seed updates the Resources tab Level Document relationship.

Empty states:

- No batch rows: show that Seed Lab has not run yet.
- No selected seed: show that promotion needs a selected row.
- No target document: show that promotion will create an unsaved promoted document in workspace context.

Non-goals:

- Do not move single-candidate Generate controls into QA.
- Do not silently use sample assets.
- Do not add analog tests.
