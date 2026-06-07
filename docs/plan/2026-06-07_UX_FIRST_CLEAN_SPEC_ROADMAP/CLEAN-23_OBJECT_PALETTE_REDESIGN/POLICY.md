# CLEAN-23 Policy

## Decisions

- Object definitions are the source of normal object keys.
- Object placement properties are edited from typed values inferred from definition defaults and current placement payload.
- Raw JSON property text is a debug/advanced backing field and is hidden from normal object mode.
- Scene resources are stored as `PackedScene`, not path strings.

## Verification

- Tests should cover definition list rows, object key selection from definitions, `PackedScene` scene assignment, and typed property controls.
- Tests should assert that normal object mode does not require raw object id or raw dictionary text editing.
