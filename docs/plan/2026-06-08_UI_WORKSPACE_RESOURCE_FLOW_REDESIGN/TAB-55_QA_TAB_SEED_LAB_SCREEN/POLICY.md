# TAB-55 Policy

Task: `TAB-55_QA_TAB_SEED_LAB_SCREEN`

Rules:

- Generate owns one immediate generation result; QA owns seed comparison and adoption.
- QA may call existing generation batch APIs, but visible QA state must include score rows, selected seed, validation summary, and promotion target.
- Promotion must update workspace Level Document context so Resources reflects the adopted document.
- Project Generation Profile and Validation Rule Suite assets remain the production path.
- Sample assets remain learning candidates only and must not become QA execution fallback.

Completion evidence:

- `tests/test_editor_plugin.gd` verifies QA Seed Lab snapshot, score rows, selected seed, promotion, and Resources Level Document update.
- `docs/TEST.md` records headless coverage.
- `./tools/test.sh` passes.
