# CLEAN-11 Policy

## Applicable Policy

- The addon is unpublished; adapter compatibility behavior is not part of the clean spec.
- UX/API clarity takes precedence over preserving fallback display for invalid documents.
- Headless tests must assert the clean adapter contract and validation result contract, not obsolete fallback rendering.

## Task Rules

- Remove public compatibility warning APIs from the document adapter.
- Do not add new migration or fallback concepts.
- Keep direct numeric adapter helpers only when they are explicit low-level tile drawing helpers.
- Classify missing catalog/default key/catalog key/resource as validation errors.
- Leave object database and catalog resource schema compatibility to their dedicated follow-up tasks.
