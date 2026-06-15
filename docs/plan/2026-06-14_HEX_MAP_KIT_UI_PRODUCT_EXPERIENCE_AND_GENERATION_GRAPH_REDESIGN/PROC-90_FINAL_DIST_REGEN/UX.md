# PROC-90 UX

## Target User

Maintainer preparing the roadmap completion state.

## Desired Experience

- The committed `dist/` files match the current addon package contents.
- Packaging remains a final process step, not a hidden requirement in every task.

## Avoided Experience

- Public upload/signing work starting from an internal roadmap task.
- Requiring dist freshness in unrelated task tests.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. regenerate dist once at final task | high | low | low | adopt | Matches queue and AGENTS rules. |
| B. add dist freshness to all tests | low | medium | medium | reject | Roadmap says final process step only. |
